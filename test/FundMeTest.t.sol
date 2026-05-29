// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumUsd() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() external view {
        assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersion() external view {
        assertEq(fundMe.getVersion(), 4);
    }
}
