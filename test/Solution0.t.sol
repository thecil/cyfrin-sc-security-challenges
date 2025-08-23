// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {S0} from "../src/challenges/S0.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Solution0Test is Test {
    S0 challenge;
    IERC721 nft;
    address constant sepoliaRegistryAddress =
        0x31801c3e09708549c1b2c9E1CFbF001399a1B9fa;
    address constant sepoliaChallengeAddress =
        0x39338138414Df90EC67dC2EE046ab78BcD4F56D9;
    address USER = makeAddr("USER");

    function setUp() public {
        // Fork Sepolia
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        // Initialize deployed contract
        challenge = S0(sepoliaChallengeAddress);
        nft = IERC721(sepoliaRegistryAddress);
    }

    function test_canReadChallengeContract() public view {
        string memory result = challenge.attribute();
        console.log("Result:", result);
        assertEq(result, "Confident", "Should be attribute:Confident");
    }

    function test_solveChallenge() public {
        vm.startPrank(USER);
        challenge.solveChallenge("thecil_eth");
        vm.stopPrank();
        console.log("NFT", nft.balanceOf(USER));
        assertEq( nft.balanceOf(USER), 1);
    }
}
