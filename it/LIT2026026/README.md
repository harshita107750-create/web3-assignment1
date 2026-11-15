# Betting Smart Contract

**Name:** Harshit Goyal
**Roll Number:** LIT2026026
**Contract Address:** 0x5A86858aA3b595FD6663c2296741eF4cd8BC4d01

## Functions Implemented

- **onlyOwner** - modifier that allows only the owner to run a function.
- **put_bet** - lets a user bet on team 1 or 2. It checks the team names are set, betting is open, the team is valid and the amount is at least the minimum. Then it saves the bet and updates the team total.
- **declare_result** - owner sets the winning team after betting is closed.
- **distribute_amount** - sends each winner their bet plus their share of the losing team's total. Multiplication is done before division to avoid rounding to zero.

Tested in Remix with 3 accounts.
