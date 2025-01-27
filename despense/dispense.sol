// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleTreeDispenser {
    address public owner;

    enum ChainType { NATIVE, TOKEN }
    mapping(address => bool) public supportedTokens; // List of supported ERC-20 tokens

    event Deposited(address indexed depositor, uint256 amount, ChainType chainType, address token);
    event Airdropped(address indexed recipient, uint256 amount, ChainType chainType, address token);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit(ChainType chainType, address token, uint256 amount) external payable {
        if (chainType == ChainType.NATIVE) {
            require(msg.value == amount, "Native token value mismatch");
            emit Deposited(msg.sender, amount, chainType, address(0));
        } else {
            require(supportedTokens[token], "Token not supported");
            require(amount > 0, "Invalid amount");

            bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
            require(success, "Token transfer failed");
            emit Deposited(msg.sender, amount, chainType, token);
        }
    }

    function airdrop(
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 totalAmount,
        ChainType chainType,
        address token
    ) external onlyOwner {
        require(recipients.length == amounts.length, "Mismatched input lengths");

        if (chainType == ChainType.NATIVE) {
            require(address(this).balance >= totalAmount, "Insufficient native token balance");

            for (uint256 i; i < recipients.length; ) {
                payable(recipients[i]).transfer(amounts[i]);
                emit Airdropped(recipients[i], amounts[i], chainType, address(0));
                unchecked {
                    ++i;
                }
            }
        } else {
            require(supportedTokens[token], "Token not supported");

            for (uint256 i; i < recipients.length; ) {
                require(
                    IERC20(token).balanceOf(address(this)) >= amounts[i],
                    "Insufficient token balance"
                );
                IERC20(token).transfer(recipients[i], amounts[i]);
                emit Airdropped(recipients[i], amounts[i], chainType, token);
                unchecked {
                    ++i;
                }
            }
        }
    }

    function setTokenSupport(address token, bool supported) external onlyOwner {
        supportedTokens[token] = supported;
    }

    function withdraw(ChainType chainType, address token, uint256 amount) external onlyOwner {
        if (chainType == ChainType.NATIVE) {
            require(address(this).balance >= amount, "Insufficient native token balance");
            payable(owner).transfer(amount);
        } else {
            require(supportedTokens[token], "Token not supported");
            require(
                IERC20(token).balanceOf(address(this)) >= amount,
                "Insufficient token balance"
            );
            IERC20(token).transfer(owner, amount);
        }
    }

    receive() external payable {}
}
