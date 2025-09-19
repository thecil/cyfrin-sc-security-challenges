// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { S3 } from "../src/challenges/S3.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Solution3 } from "../src/solutions/Solution3.sol";

contract Solution3Test is Test {
    S3 challenge;
    Solution3 solution;
    IERC721 nft;
    address constant sepoliaRegistryAddress = 0x31801c3e09708549c1b2c9E1CFbF001399a1B9fa;
    address constant sepoliaChallengeAddress = 0xA2626bE06C11211A44fb6cA324A67EBDBCd30B70;
    address USER = makeAddr("USER");

    function setUp() public {
        // Fork Sepolia
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        // Initialize deployed contract
        challenge = S3(sepoliaChallengeAddress);
        nft = IERC721(sepoliaRegistryAddress);
        // user deploy the solution contract in order to have same owner
        vm.startPrank(USER);
        solution = new Solution3(challenge, nft);
        vm.stopPrank();
    }

    function test_canReadChallengeContract() public view {
        string memory result = challenge.description();
        console.log("Result:", result);
        assertEq(result, "Section 3: PasswordStore", "Should be description: Section 3: PasswordStore");
    }

    function _getEventTransfer() internal returns (address from, address to, uint256 tokenId) {
        // Get recorded logs
        Vm.Log[] memory logEntries = vm.getRecordedLogs();
        // Get the first log entry which should be the event 'Transfer'
        Vm.Log memory logEntry = logEntries[0];
        // Recall that log entry topics[0] is the event signature
        bytes32 eventSignature = keccak256("Transfer(address,address,uint256)");

        assertEq(logEntry.topics[0], eventSignature, "The event signature hash should match Transfer Event");
        // Decode indexed params from topics
        from = address(uint160(uint256(logEntry.topics[1])));
        to = address(uint160(uint256(logEntry.topics[2])));
        tokenId = uint256(logEntry.topics[3]);

        console.log("Transfer Event Decoded: from: %s, to: %s, tokenId: %s", from, to, tokenId);
    }

    function test_solveChallenge() public {
        // find the slot of the number we want to change
        bytes32 slot = vm.load(address(challenge), bytes32(uint256(777)));
        console.logBytes32(slot);
        console.log("slot: ", uint256(slot));
        vm.startPrank(USER);
        // Start recording
        vm.recordLogs();
        solution.solve(uint256(slot));
        vm.stopPrank();
        console.log("NFT", nft.balanceOf(address(solution)));
        assertEq(nft.balanceOf(address(solution)), 1);
        // transfer nft to USER, to ensure we can rescue the NFT from the contract
        vm.startPrank(USER);
        (,, uint256 tokenId) = _getEventTransfer();
        solution.withdrawNft(tokenId);
        assertEq(nft.balanceOf(address(solution)), 0, "Contract should not have any NFT at this point");
        assertEq(nft.balanceOf(USER), 1, "USER should have 1 NFT at this point");
        assertEq(nft.ownerOf(tokenId), USER, "NFT should be owned by USER");
        vm.stopPrank();
    }
}
