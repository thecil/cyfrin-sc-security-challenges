// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { S0 } from "../challenges/S0.sol";

contract Solution0 is ERC721Holder {
    error Solution0__SolveFailed();
    error Solution0__IncorrectOwnedTokenId();

    S0 public immutable i_challenge;
    IERC721 public immutable i_nft;

    constructor(S0 _challenge, IERC721 _nft) {
        i_challenge = (_challenge);
        i_nft = _nft;
    }

    function owner() external view returns (address) {
        return address(this);
    }

    function solve() external {
        i_challenge.solveChallenge("thecil_eth");
    }

    function withdrawNft(uint256 _tokenId) external {
        if (i_nft.ownerOf(_tokenId) != address(this)) {
            revert Solution0__IncorrectOwnedTokenId();
        }
        i_nft.safeTransferFrom(address(this), msg.sender, _tokenId, "");
    }
}
