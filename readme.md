UrbanCohort PascalCoin FireMonkey Wallet

Copyright (c) 2016-2019 PascalCoin developers based on original Albert Molina source code

This version is copyright (c) 2019 Russell Weetch, subject to the above copyright
  
THIS IS EXPERIMENTAL SOFTWARE. Use it for educational purposes only.  
    
Distributed under the MIT software license, see the accompanying file  
LICENSE  or visit http://www.opensource.org/licenses/mit-license.php.  


This is a Wallet for PascalCoin developed in Delphi Firemonkey and uses the PascalCoin JSON RPC for on chain actaions. It has been developed in Delphi (10.3) Rio but I've not used any of the 10.3 language enhancements (like inlibe variables) so it should be ok with Seattle and Berlin. Please let me know if I need to make chnages for this and I'll give it some consideration.

The approach has been to interface everything and so features that are taken from PascalCoin/Core, from Albert Molina et al, have been re-envisioned in this framework, although the underlying code is the same. This is the same for PascalCoin KeyTools from library by Ugochukwu Mmaduekwe although this is not needed for this project).

The project uses Spring4Delphi container to provide dependency injection in a rough and ready way, but it does give a single point to see what interfaces and classes are used and that you don't need to remember what secondary objects need to be instantiated (and of course it is simpler to provide alternatives).

There are a few external dependancies you need for to have installed:

Crypto Libraries:

SimplebaseLib4Pascal: https://github.com/Xor-el/SimpleBaseLib4Pascal
HashLib4Pascal: https://github.com/Xor-el/HashLib4Pascal
CryptoLib4Pascal: https://github.com/xor-el/cryptoLib4Pascal/

Note that if you have PascalCoin/Core installed then these can be found in the libararies sub directory.

Other external ibraries needed:

FrameStand: available via GetIt package manager or at https://github.com/andrea-magni/TFrameStand
Spring4D: https://bitbucket.org/sglienke/spring4d


At the moment the testnet data for the app is held in C:\Users\<user>\AppData\Roaming\PascalCoin_URBAN you can get a quick start bu copying the contents of  C:\Users\<user>\AppData\Roaming\PascalCoin_TESTNET to this folder.


Other repositories, although not needed for this project they are needed as reference points at least

PascalCoin/Core: https://github.com/PascalCoin/PascalCoin
PascalCoin/PascalCoinTools: https://github.com/PascalCoin/PascalCoinTools

if you like this you can send me donations:

PASC: 127501-23
BTC:  3GsyvoSY9EqJnW5VFhpUUhGLgKKTTsYAEQ
ETH:  0xdEf093C4121B07B9a2709E553D1f0E0a72Ef3887
