// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {S3} from "../src/challenges/S3.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Solution3Test is Test {
    S3 challenge;
    IERC721 nft;
    address constant sepoliaRegistryAddress =
        0x31801c3e09708549c1b2c9E1CFbF001399a1B9fa;
    address constant sepoliaChallengeAddress =
        0xA2626bE06C11211A44fb6cA324A67EBDBCd30B70;
    address USER = makeAddr("USER");

    function setUp() public {
        // Fork Sepolia
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        // Initialize deployed contract
        challenge = S3(sepoliaChallengeAddress);
        nft = IERC721(sepoliaRegistryAddress);
    }

    function test_canReadChallengeContract() public view {
        string memory result = challenge.attribute();
        console.log("Result:", result);
        assertEq(result, "Repeater", "Should be attribute:Repeater");
    }

    function test_solveChallenge() public {
        // find the slot of the number we want to change
        bytes32 slot = vm.load(address(challenge), bytes32(uint256(777)));
        console.logBytes32(slot);
        console.log("slot: ", uint256(slot));
        vm.startPrank(USER);
        challenge.solveChallenge(uint256(slot), "thecil_eth");
        vm.stopPrank();
        console.log("NFT", nft.balanceOf(USER));
        assertEq(nft.balanceOf(USER), 1);
    }
}
