// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { S1 } from "../src/challenges/S1.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Solution1Test is Test {
    S1 challenge;
    IERC721 nft;
    address constant sepoliaRegistryAddress = 0x31801c3e09708549c1b2c9E1CFbF001399a1B9fa;
    address constant sepoliaChallengeAddress = 0x76D2403b80591d5F6AF2b468BC14205fa5452AC0;
    address USER = makeAddr("USER");

    function setUp() public {
        // Fork Sepolia
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        // Initialize deployed contract
        challenge = S1(sepoliaChallengeAddress);
        nft = IERC721(sepoliaRegistryAddress);
    }

    function test_canReadChallengeContract() public view {
        string memory result = challenge.description();
        console.log("Result:", result);
        assertEq(result, "Section 1: Refresher", "Should be description: Section 1: Refresher");
    }

    function test_solveChallenge() public {
        // @param the function selector of the first one you need to call
        // the first function from the helperContract
        bytes4 selector = bytes4(keccak256("returnTrue()"));
        // @param the abi encoded data... hint! Use chisel to figure out what to use here...
        // the second function from the helperContract with correct params args
        bytes memory inputData = abi.encodeWithSelector(
            bytes4(keccak256("returnTrueWithGoodValues(uint256,address)")), 9, challenge.getHelperContract()
        );
        console.logBytes4(selector);
        console.logBytes(inputData);
        vm.startPrank(USER);
        challenge.solveChallenge(selector, inputData, "thecil_eth");
        vm.stopPrank();
        console.log("NFT", nft.balanceOf(USER));
        assertEq(nft.balanceOf(USER), 1);
    }
}
