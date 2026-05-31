// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe } from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    address USER2 = makeAddr("user2");
    uint256 constant SEND_VALUE = 1e18; // 1 ETH
    uint256 constant STARTING_BALANCE = 10e18; // 10 ETH

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
        vm.deal(USER2, STARTING_BALANCE);
    }

    function testMinimumUsd() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() external view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() external view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() external {
        vm.expectRevert();
        fundMe.fund{ value: 5e14 }(); // 5e14 = 0.0005 ETH
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{ value: SEND_VALUE }();
        _;
    }

    function testFundUpdatesDataStructures() external funded {
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
        assertEq(fundMe.getFunder(0), USER);
    }

    function testAddsFunderToArrayOfFunders() external funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    function testAddressesToAmountFunded() external {
        vm.startPrank(USER);
        fundMe.fund{ value: 1e18 }();
        fundMe.fund{ value: 15e17 }();
        vm.stopPrank();

        vm.prank(USER2);
        fundMe.fund{ value: 1e18 }();

        assertEq(fundMe.getAddressToAmountFunded(USER), 25e17);
        assertEq(fundMe.getAddressToAmountFunded(USER2), 1e18);
    }

    function testOnlyOwnerCanWithdraw() external funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() external funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() external funded {
        uint160 numberOfFunders = 10;
        for (uint160 i = 1; i <= numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{ value: SEND_VALUE }();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }
}
