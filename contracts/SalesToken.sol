pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract SalesToken is StandardToken, Ownable {

	string public constant name = "OpenProductDb.com token";
	string public constant symbol = "OPDB";
	uint8 public constant decimals = 18;

	address public walletSales;
	address public walletOther;

	uint256 public constant SUPPLY_TOTAL = 50000000 ether;
	uint256 public constant SUPPLY_OTHER = 22500000 ether;

	uint public dateEnd;

	modifier whenNotPaused() {
		require(now >= dateEnd);
		_;
	}

	function SalesToken(address _walletSales, address _walletOther, uint _dateEnd) public {
		totalSupply_ = SUPPLY_TOTAL;
		dateEnd = _dateEnd;
		walletSales = _walletSales;
		walletOther = _walletOther;
		// Split tokens by wallets
		balances[walletOther] = SUPPLY_OTHER;
		balances[walletSales] = SUPPLY_TOTAL - balances[walletOther];
		Transfer(0x0, walletOther, balances[walletOther]);
		Transfer(0x0, walletSales, balances[walletSales]);
	}

	// Transfers disabled before dateEnd
	function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
		return super.transfer(_to, _value);
	}

	// Transfers disabled before dateEnd
	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
		return super.transferFrom(_from, _to, _value);
	}

	function sendTokens(address _to, uint _amount) external onlyOwner {
		require(_amount <= balances[walletSales]);
		balances[walletSales] -= _amount;
		balances[_to] += _amount;
		Transfer(walletSales, msg.sender, _amount);
	}
}
