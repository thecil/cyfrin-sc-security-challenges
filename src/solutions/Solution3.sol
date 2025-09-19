// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { S3 } from "../challenges/S3.sol";

contract Solution3 is ERC721Holder {
    error Solution3__SolveFailed();
    error Solution3__IncorrectOwnedTokenId();

    S3 public immutable i_challenge;
    IERC721 public immutable i_nft;

    constructor(S3 _challenge, IERC721 _nft) {
        i_challenge = (_challenge);
        i_nft = _nft;
    }

    function owner() external view returns (address) {
        return address(this);
    }

    function readStorage(uint256 storageSlot) public view returns (uint256 vauleAtStorageSlot) {
        assembly {
            vauleAtStorageSlot := sload(storageSlot)
        }
    }

    /// @param _slot - The value at storage location 777.
    function solve(uint256 _slot) external {
        i_challenge.solveChallenge(_slot, "thecil_eth");
    }

    function withdrawNft(uint256 _tokenId) external {
        if (i_nft.ownerOf(_tokenId) != address(this)) {
            revert Solution3__IncorrectOwnedTokenId();
        }
        i_nft.safeTransferFrom(address(this), msg.sender, _tokenId, "");
    }
}
