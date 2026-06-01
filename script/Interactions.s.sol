// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script, console } from "forge-std/Script.sol";
import { DevOpsTools } from "foundry-devops/src/DevOpsTools.sol";
import { FundMe } from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployment)).fund{ value: SEND_VALUE }();
        vm.stopBroadcast();
        console.log("Funded FundMe %s with %s wei", mostRecentDeployment, SEND_VALUE);
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(contractAddress);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployment)).withdraw();
        vm.stopBroadcast();

        address owner = FundMe(payable(mostRecentDeployment)).getOwner();
        console.log("Withdrew from FundMe %s", mostRecentDeployment);
        console.log("Owner %s has balance %s", owner, owner.balance);
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(contractAddress);
    }
}
