// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Distribute {
    using SafeMath for uint256;

    event TokensReleased(uint256 amount, uint256 height);
    event TokensRevoked(uint256 amount, address to);

    // init in constructor
    IERC20 public token;

    // adjustable by the owner
    address public beneficiary;
    uint256 public startBlock;
    uint256 public stableHeight = 30;
    uint256 public blocksPerCycle = 6600;
    uint256 public releasedPerBlock;

    uint256 public totalReleased;
    uint256 public latestReleasedHeight;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor (address tokenAddr) public {
        require(tokenAddr != address(0), "token is the zero address");
        token = IERC20(tokenAddr);
        owner = msg.sender;
        startBlock = block.number;
        latestReleasedHeight = startBlock;
    }

    function setBeneficiary(address addr) onlyOwner public {
        require(addr != address(0), "beneficiary is the zero address");
        beneficiary = addr;
    }

    function setStartBlock(uint256 start) onlyOwner public {
        require(start > latestReleasedHeight, "start is lower than latestReleasedHeight");
        startBlock = start;
        latestReleasedHeight = startBlock;
    }

    function setStableHeight(uint256 stable) onlyOwner public {
        require(stable < blocksPerCycle, "stable height is longer than blocks per cycle");
        stableHeight = stable;
    }

    function setBlocksPerCycle(uint256 count) onlyOwner public {
        require(count > stableHeight, "blocks per cycle is lower than stable height");
        blocksPerCycle = count;
    }

    function setReleasedPerBlock(uint256 amount) onlyOwner public {
        releasedPerBlock = amount;
    }

    function revoke() onlyOwner public {
        uint256 currentBalance = token.balanceOf(address(this));
        require(currentBalance > 0, "balance is zero");

        token.transfer(owner, currentBalance);

        emit TokensRevoked(currentBalance, owner);
    }

    function release() public {
        require(beneficiary != address(0), "beneficiary is not set");

        (uint256 unreleased, uint256 height) = releasableAmount();
        require(unreleased > 0, "Distribute: no tokens are due");

        uint256 currentBalance = token.balanceOf(address(this));
        if (unreleased > currentBalance) {
            unreleased = currentBalance;
            require(unreleased > 0, "Distribute: no tokens are due");
        }

        totalReleased = totalReleased.add(unreleased);

        latestReleasedHeight = height;

        token.transfer(beneficiary, unreleased);

        emit TokensReleased(unreleased, height);
    }

    function releasableAmount() public view returns (uint256 amount, uint256 height) {
        if (releasedPerBlock == 0 || block.number < latestReleasedHeight) {
            return (0, latestReleasedHeight);
        }

        uint256 cycles = block.number.sub(latestReleasedHeight).div(blocksPerCycle);
        height = latestReleasedHeight.add(cycles.mul(blocksPerCycle));

        if (cycles > 0 && block.number.sub(height) < stableHeight) {
            cycles = cycles.sub(1);
            height = height.sub(blocksPerCycle);
        }

        if (cycles == 0) {
            return (0, height);
        }

        amount = cycles.mul(blocksPerCycle).mul(releasedPerBlock);
        return (amount, height);
    }
}
