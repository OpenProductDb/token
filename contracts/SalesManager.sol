pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./SalesToken.sol";

contract SalesManager is Ownable {

	using SafeMath for uint256;

	struct Stat {
		uint raised;
		uint numEth;
		uint numTx;
	}

	Stat public stat;

	// NOTE: Testing-only
	// -- uint public constant dateShift    = 5 days;
	//
	uint public constant dateStart    = 1519819200 /* - dateShift*/;	//	2018-02-28T12:00:00+00:00
	uint public constant dateEndPRE   = dateStart + 6 weeks;
	uint public constant dateStartICO = 1523880000 /*- dateShift*/;		//	2018-04-16T12:00:00+00:00
	uint public constant dateEnd      = dateStartICO + 8 weeks;

	uint public constant capPRE = 2500000 ether;
	uint public constant capICO = 25000000 ether;

	uint256 tokenPerEth = 1000;
	uint256 tokenMinEth = 0.1 ether;

	address public tokenAddress = 0x0;

	address public walletSales = 0x0;
	address public walletOther = 0x0;

	// @dev modifier to allow actions only when end date is now
	modifier isFinished() {
		require(now >= dateEnd);
		_;
	}

	function SalesManager (address _walletSales, address _walletOther) public {
		require(_walletSales != address(0));
		require(_walletOther != address(0));
		walletSales = _walletSales;
		walletOther = _walletOther;
		tokenAddress = new SalesToken(walletSales, walletOther, dateEnd);
	}

	function isPRE() public view returns (bool) {
		if (now >= dateStart && now < dateEndPRE) {
			return true;
		} else {
			return false;
		}
	}

	function isICO() public view returns (bool) {
		if (now >= dateStartICO && now < dateEnd) {
			return true;
		} else {
			return false;
		}
	}

	function () payable public {
		if (msg.value < tokenMinEth || (!isPRE() && !isICO())) revert();
		buyTokens();
	}

	function buyTokens() internal {
		uint256 tokens = 0;
		uint256 tokensAmount = msg.value.mul(tokenPerEth);
		uint256 bonus = 0;
		uint256 tokensBonus = 0;
		uint256 balance = 0;
		// Two stages logic
		if (isPRE()) {
			// Weekly bonuses
			if ( now <= (dateStart + 1 weeks) ) {
				bonus = 100;
			} else if ( now > (dateStart + 1 weeks) && now <= (dateStart + 2 weeks) ) {
				bonus =  90;
			} else if ( now > (dateStart + 2 weeks) && now <= (dateStart + 3 weeks) ) {
				bonus =  85;
			} else if ( now > (dateStart + 3 weeks) && now <= (dateStart + 4 weeks)) {
				bonus =  80;
			} else if ( now > (dateStart + 4 weeks) && now <= (dateStart + 5 weeks)) {
				bonus =  75;
			} else {
				bonus =  70;
			}
			// tokensBonus = tokensAmount * bonus / 100;
			tokensBonus = tokensAmount.mul(bonus).div(100);
			// Cap
			balance = capPRE.sub(stat.raised);
			tokens = tokensAmount.add(tokensBonus);
			if (balance >= tokens) {
				sendTokens(tokens, msg.value);
			} else {
				revert();
			}
		} else if (isICO()) {
			// Weekly bonuses
			if ( now <= (dateStartICO + 1 weeks) ) {
				bonus = 50;
			} else if ( now > (dateStartICO + 1 weeks) && now <= (dateStartICO + 2 weeks) ) {
				bonus = 45;
			} else if ( now > (dateStartICO + 2 weeks) && now <= (dateStartICO + 3 weeks) ) {
				bonus = 40;
			} else if ( now > (dateStartICO + 3 weeks) && now <= (dateStartICO + 4 weeks)) {
				bonus = 35;
			} else if ( now > (dateStartICO + 4 weeks) && now <= (dateStartICO + 5 weeks)) {
				bonus = 30;
			} else if ( now > (dateStartICO + 5 weeks) && now <= (dateStartICO + 6 weeks)) {
				bonus = 25;
			} else if ( now > (dateStartICO + 6 weeks) && now <= (dateStartICO + 7 weeks)) {
				bonus = 20;
			} else {
				bonus = 15;
			}
			// tokensBonus = tokensAmount * bonus / 100;
			tokensBonus = tokensAmount.mul(bonus).div(100);
			// Cap
			balance = capICO.sub(stat.raised);
			tokens = tokensAmount.add(tokensBonus);
			if (balance >= tokens) {
				sendTokens(tokens, msg.value);
			} else {
				revert();
			}
		} else {
			revert();
		}
	}

	function sendTokens(uint _amount, uint _ethers) internal {
		SalesToken tokenHolder = SalesToken(tokenAddress);
		tokenHolder.sendTokens(msg.sender, _amount);
		stat.raised += _amount;
		walletSales.transfer(_ethers);
		stat.numEth += _ethers;
		stat.numTx += 1;
	}

	// public onlyOwner

	// For fiat investors
	function sendTokensManually(address _to, uint _amount) public onlyOwner {
		require(_to != address(0));
		SalesToken tokenHolder = SalesToken(tokenAddress);
		tokenHolder.sendTokens(_to, _amount);
		stat.raised += _amount;
		stat.numTx += 1;
	}

	// Сhange token price
	function setTokenPerEth(uint _tokenPerEth) public onlyOwner {
		tokenPerEth = _tokenPerEth;
	}

	// Сhange minimal pay
	function setTokenMinEth(uint _tokenMinEth) public onlyOwner {
		tokenMinEth = _tokenMinEth;
	}

}
