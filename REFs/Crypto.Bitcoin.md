# [Bitcoin](https://en.wikipedia.org/wiki/Bitcoin "Wikipedia")  Usage 

## Exchanges / Wallets (Bootstrap)
1. Create an account at __[Coinbase](https://www.coinbase.com/)__ or __[CashApp](https://cash.app/)__ __exchange__
    - ___links___ your ___identity___ &amp; ___bank account___.
    - ___Use___ it ___only as___ an ___exchange___ ( crypto to/from cash).
    - ___Do not use___ this account ___as your wallet___.
1. Purchase some trivial amount of bitcoin at the exchange.
1. Install __[Electrum](https://electrum.org/) wallet__ on your desktop machine.
    - Generates the ___passphrase___; a 12 word code (_seed_).
1. Send the money from your exchange account to your Electrum wallet.
1. Install __[Mycelium](https://wallet.mycelium.com/) wallet__ on your phone. 
    - Handles QR codes; info is amount &amp; address to send to.
1. Send some of the money in your Electrum wallet to your Mycelium wallet.

So, the offline wallet (Electrum) is like your savings account, holding the bulk of your crypto, and the online wallet (Mycelium) is like your checking account, holding only that which you need for routine, near-term transactions.

A _wallet_ maintains ___bitcoin address(es)___; record(s) on the distributed blockchain; accessible from anywhere, and ___secured by the passphrase___.

#### _Do not use a crypto exchange as a wallet_: 

A foundational idea of cryptocurrency is that it has no central (single) authority controlling it. Yet crypto exchanges are just that, when used as your crypto store (wallet).

- Crypto exchanges may converge with the other lawless financial institutions, which are notorious for engaging in blatant discrimination against customers in good standing, at the whims of depraved political commissars; [blacklisting customers](https://www.breitbart.com/tech/2019/02/27/financial-blacklisting-chase-bank-withdraws-service-from-independent-and-conservative-figures/ "2019 @ Breitbart"). 
- Crypto exchanges are notorious for looting of customers' accounts, in [example](https://www.cnbc.com/2019/05/08/binance-bitcoin-hack-over-40-million-of-cryptocurrency-stolen.html) after [example](https://www.forbes.com/sites/francescoppola/2018/02/11/yet-another-theft-from-a-cryptocurrency-exchange-but-who-is-really-to-blame/#4e47df4af6dd), after [example](https://www.bbc.com/news/world-asia-42845505); they, not you, hold the private key.

___The private key___ (seed a.k.a. passphrase) ___should never be shared___; only the bitcoin (account) owner should have access to it. 

>_&ldquo;Your bitcoins are only as safe as their private keys.&rdquo;_

This is fundamental to all such cryptography (PKE), not merely Bitcoin.

## Gift Cards / Mobile Refills

[Bitrefill](https://www.bitrefill.com/) &mdash; Live on Crypto

>Purchase ___Gift Cards___ or ___Mobile Refills___ from more than 1650 businesses in 170 countries. Get eGifts & pay mobile bills quickly, safely, &hellip; ___using cryptocurrencies___.

1. Enter (fake) ___email address___ to get QR code.
1. Scan & Send using your Mycelium wallet:
    - Click `send`, which opens the phone's camera.
    - Scan the QR code, which loads the amount and the (crypto) address to send it to.
    - Click `send`.

Transaction time is 1-10 minutes. After which you will be given a code to enter at recipient to claim the Card/Refill amount. 

## Bitcoin ATMs

[Coinstar](https://www.coinstar.com/bitcoin) [Kiosk](https://www.coinstar.com/findakiosk/?ProductId=100013 "Find nearest") (Vending machine)

1. Click "Buy Bitcoin"
    - Enter (fake) ___phone number___ 
    - Enter cash; ___dollar bills___ (not coins) 
1. Receive voucher with a Bitcoin redemption code.

## Technical Description

```plaintext
Bitcoin: A Peer-to-Peer Electronic Cash System

by Satoshi Nakamoto
satoshin@gmx.com
www.bitcoin.org
```

A blockchain is a cryptographically ([PKE](https://en.wikipedia.org/wiki/Public-key_cryptography "Public-key Encryption @ Wikipedia")) secured append-only log; a [distributed ledger](https://en.wikipedia.org/wiki/Distributed_ledger "Wikipedia") (addressed per [hash](https://en.wikipedia.org/wiki/Cryptographic_hash_function "Wikipedia")) whereof a new log entry (_chain mutation_ a.k.a. _transaction_ a.k.a. _block_) occurs only by some [_consensus algorithm_](https://en.wikipedia.org/wiki/Consensus_%28computer_science%29 "Wikipedia") (work performed by a network of constituent nodes). 

A cryptocurrency is simply its blockchain and the code required for mutating it per some [P2P](https://en.wikipedia.org/wiki/Peer-to-peer "'Peer-to-Peer' @ Wikipedia") network [API](https://en.wikipedia.org/wiki/Application_programming_interface "'Applicaion Programming Interface' @ Wikipedia"). A bitcoin _account_ is fundamentally nothing but a construct of the mind; as much so as any US financial account. A block of bitcoin (an entry in the ledger) is _owned_ by whomever, or whatever, has access to the private key (pair) of the public key stored therein. Thus a private key is the proxy for its _bitcoin_; for that in its (quite public bitcoin) block.

A [transaction](https://en.bitcoin.it/wiki/Transaction "en.bitcoin.it/wiki") is an entry (a new block) appended to the log (blockchain). A transaction can have many recipients. Each entry requires both the sender's ___signature___ (per owner's private &amp; public key) and the public key(s) of the recipient(s). Note this _signing_ is ___the one part of the transaction that must be secured___. 

The transfer (of ownership) occurs by simply _changing_ the private key locking the amount transacted upon, from that of the sender to that of the recipient(s). Yet instead of actually changing an _existing_ block, a new block is appended to the blockchain. (Blocks are immutable.) 

Nothing is actually _sent_ anywhere, and there is no _thing_ other than the sum of all transaction records (the distributed ledger; blockchain). Each such record (block) includes its amount (₿), the new owner (their public key), and the (prior) transaction (hash address from whence it came). Thus forming a (growing) _chain_ of such (immutable) _blocks_.

A _wallet_ (a.k.a. vault) is any application (some wed to hardware) &mdash; orthogonal to the blockchain &mdash;that stores both public and private key pair(s) to such block(s), and secures them (damn well better), providing a password-based user interace for initiating (signing for) a transaction. That is, a cryptocurrency wallet is a PKE key store/manager. It only _contains_ bitcoins in the sense that it contains (and secures) their proxy, the private key(s) thereto.

### [Bitcoin Transaction](https://en.bitcoin.it/wiki/Transaction "en.bitcoin.it/wiki")

![Bitcoin_Transaction_Visual.png](Bitcoin_Transaction_Visual.svg)

> Note the ___passphrase___ (seed) and the [___private key___](https://privatekeys.pw/bitcoin/keys/1) are two different things. The former is generated (by a wallet application) to secure the latter. They are often referenced synonymously to convey the underlying concepts sans clutter of technical minutia. 

## Unicode Glyph ₿

### [`BITCOIN SIGN`](https://www.fileformat.info/info/unicode/char/20bf/index.htm "fileformat.info") (U+20BF) 

## HTML Entity &#x20bf;

### `&#x20bf;` 


### &nbsp;


<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (MD | HTML)

([MD](___.html "@ browser"))   


# Bookmark

- Reference
[Foo](#foo)
- Target
<a name="foo"></a>

-->

