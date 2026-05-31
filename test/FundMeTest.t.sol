// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe } from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 1e18; // 1 ETH
    uint256 constant STARTING_BALANCE = 10e18; // 10 ETH

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsd() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() external view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() external view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() external {
        vm.expectRevert();
        fundMe.fund{ value: 5e14 }(); // 5e14 = 0.0005 ETH
    }

    function testFundUpdatesDataStructures() external {
        vm.prank(USER);
        fundMe.fund{ value: SEND_VALUE }();
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
        assertEq(fundMe.getFunder(0), USER);
    }
}
