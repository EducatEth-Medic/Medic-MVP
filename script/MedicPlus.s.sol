// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Script} from "lib/forge-std/src/Script.sol";
import {console} from "lib/forge-std/src/Test.sol";
// import "forge-std/Test.sol";
// import "lib/forge-std/src/Test.sol";
import {MedicPlusManager} from "../src/MedicPlus.sol";

contract MedicPlusScript is Script {
    MedicPlusManager public medicPlus;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        console.log("Deployer private key: ", deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        medicPlus = new MedicPlusManager();

        console.log("Medic+ deployed at: ", address(medicPlus));
        vm.stopBroadcast();
    }
}
