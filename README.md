# Token

Smart contracts for [OpenProductDb](https://OpenProductDb.com)

Based on [zeppelin-solidity](https://github.com/OpenZeppelin/zeppelin-solidity) v.1.6.0


## SalesToken

*	The total number of available tokens = `50 000 000` tokens

*	All tokens initially splitted into 2 wallets
	*	`walletSales` -- Tokens for sale (preICO and ICO) = `27 500 000` tokens
	*	`walletOther` -- Team, bounty, advisors, etc = `22 500 000` tokens

*	Can't be transferred before `dateEnd`


## SalesManager

*	Two stages
	*	PreICO
	*	ICO

*	Bonus subsystem
	*	Per-week bonuses

