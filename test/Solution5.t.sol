// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { S5 } from "../src/challenges/S5.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Solution5 } from "../src/solutions/Solution5.sol";

contract Solution5Test is Test {
    S5 challenge;
    Solution5 solution;
    IERC721 nft;
    address constant sepoliaRegistryAddress = 0x31801c3e09708549c1b2c9E1CFbF001399a1B9fa;
    address constant sepoliaChallengeAddress = 0xdeB8d8eFeF7049E280Af1d5FE3a380F3BE93B648;
    address USER = makeAddr("USER");

    function setUp() public {
        // Fork Sepolia
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        // Initialize deployed contract
        challenge = S5(sepoliaChallengeAddress);
        nft = IERC721(sepoliaRegistryAddress);
        // user deploy the solution contract in order to have same owner
        vm.startPrank(USER);
        solution = new Solution5(challenge, nft);
        vm.stopPrank();
    }

    function test_canReadChallengeContract() public view {
        string memory result = challenge.description();
        console.log("Result:", result);
        assertEq(result, "Section 5: T-Swap!", "Should be description: Section 5: T-Swap!");
    }

    function _getNftTokenIdFromLogs() private returns (uint256) {
        // Get recorded logs
        Vm.Log[] memory logEntries = vm.getRecordedLogs();
        console.log("LOG LENGTH", logEntries.length);

        // Recall that log entry topics[0] is the event signature
        bytes32 eventSignature = keccak256("Transfer(address,address,uint256)");

        // Loop through the array to find the 'logEntry.emitter' to be equal to 'nft'
        for (uint256 i = 0; i < logEntries.length; i++) {
            Vm.Log memory logEntry = logEntries[i];

            if (logEntry.emitter == address(nft)) {
                assertEq(logEntry.topics[0], eventSignature, "The event signature hash should match Transfer Event");

                // Decode indexed params from topics
                uint256 tokenId = uint256(logEntry.topics[3]);
                return tokenId;
            }
        }

        // If no log entry is found for the 'i_nft', return 0 or handle accordingly
        return 0;
    }

    function test_solveChallenge() public {
        vm.startPrank(USER);
        // Start recording
        vm.recordLogs();
        solution.solve();
        vm.stopPrank();
        console.log("NFT", nft.balanceOf(address(solution)));
        assertEq(nft.balanceOf(address(solution)), 1);
        // transfer nft to USER, to ensure we can rescue the NFT from the contract
        vm.startPrank(USER);
        uint256 tokenId = _getNftTokenIdFromLogs();
        solution.withdrawNft(tokenId);
        assertEq(nft.balanceOf(address(solution)), 0, "Contract should not have any NFT at this point");
        assertEq(nft.balanceOf(USER), 1, "USER should have 1 NFT at this point");
        assertEq(nft.ownerOf(tokenId), USER, "NFT should be owned by USER");
        vm.stopPrank();
    }
}
