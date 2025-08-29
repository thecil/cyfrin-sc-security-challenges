// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {S5} from "../../src/challenges/S5.sol";
import {S5Pool} from "../../src/challenges/S5Pool.sol";
import {S5Handler} from "./S5Handler.t.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @dev invariant config used to complete the challenge
/// @dev might have unknown results if runs are increased
/// @dev not sure if is related that solver already have the nft from past runs
/// [invariant]
/// runs = 1
/// depth = 32
/// fail_on_revert = true

contract S5Invariant is StdInvariant, Test {
    S5 challenge;
    S5Pool pool;
    S5Handler handler;
    IERC721 nft;

    uint64 constant ACTORS_LIMIT = 5;
    address constant sepoliaRegistryAddress =
        0x31801c3e09708549c1b2c9E1CFbF001399a1B9fa;
    address constant sepoliaChallengeAddress =
        0xdeB8d8eFeF7049E280Af1d5FE3a380F3BE93B648;

    function setUp() public {
        // actors management
        address[] memory actors = new address[](ACTORS_LIMIT);
        for (uint256 i = 0; i < ACTORS_LIMIT; i++) {
            actors[i] = makeAddr(vm.toString(i));
        }
        // Fork Sepolia
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        nft = IERC721(sepoliaRegistryAddress);
        challenge = S5(sepoliaChallengeAddress);
        // reset the game so we can start over
        challenge.hardReset();
        pool = S5Pool(challenge.getPool());

        handler = new S5Handler(sepoliaChallengeAddress, actors);

        targetContract(address(handler));
    }

    function invariant_solveChallenge() public view {
        console.log("Mints: %s", handler.mintsCounter());
        console.log("Deposits: %s", handler.depositsCounter());
        console.log("Swaps: %s", handler.swapsCounter());
        console.log("Solver: %s", handler.challengeResolver());
        if (handler.challengeSolved()) {
            assert(handler.challengeResolver() != address(0));
            assertEq(nft.balanceOf(handler.challengeResolver()), 1);
        }
    }

    function invariant_correctContract() public view {
        string memory result = challenge.description();
        console.log("Result:", result);
        assertEq(
            result,
            "Section 5: T-Swap!",
            "Should be description: Section 5: T-Swap!"
        );
    }
}
