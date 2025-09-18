// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { S1 } from "../challenges/S1.sol";

contract Solution1 is ERC721Holder {
    error Solution1__SolveFailed();
    error Solution1__IncorrectOwnedTokenId();

    S1 public immutable i_challenge;
    IERC721 public immutable i_nft;

    constructor(S1 _challenge, IERC721 _nft) {
        i_challenge = (_challenge);
        i_nft = _nft;
    }

    function owner() external view returns (address) {
        return address(this);
    }

    function solve() external {
        // @param the function selector of the first one you need to call
        // the first function from the helperContract
        bytes4 selector = bytes4(keccak256("returnTrue()"));
        // @param the abi encoded data... hint! Use chisel to figure out what to use here...
        // the second function from the helperContract with correct params args
        bytes memory inputData = abi.encodeWithSelector(
            bytes4(keccak256("returnTrueWithGoodValues(uint256,address)")), 9, i_challenge.getHelperContract()
        );
        i_challenge.solveChallenge(selector, inputData, "thecil_eth");
    }

    function withdrawNft(uint256 _tokenId) external {
        if (i_nft.ownerOf(_tokenId) != address(this)) {
            revert Solution1__IncorrectOwnedTokenId();
        }
        i_nft.safeTransferFrom(address(this), msg.sender, _tokenId, "");
    }
}
