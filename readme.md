UrbanCohort PascalCoin FireMonkey Wallet

Copyright (c) 2016-2019 PascalCoin developers based on original Albert Molina source code

This version is copyright (c) 2019 Russell Weetch, subject to the above copyright
  
THIS IS EXPERIMENTAL SOFTWARE. Use it for educational purposes only.  
    
Distributed under the MIT software license, see the accompanying file  
LICENSE  or visit http://www.opensource.org/licenses/mit-license.php.  


To keep to the spirit of PascalCoin this is a Wallet for PascalCoin developed in Delphi Firemonkey and uses the PascalCoin JSON RPC for on chain actaions. It has been developed in Delphi (10.3) Rio but I've not used any of the 10.3 language enhancements (like inlibe variables) so it should be ok with Seattle and Berlin. Please let me know if I need to make changes for this and I'll give it some consideration.

Using Firemonkey means that it can be built for Windows 32 & 64, Mac OSX (32 at the moment), Android and iOS.

The approach has been to keep things as simple as possible with the option to allow advanced use (see the advanced switch in settings, although it only does a few things at the moment). The technical approach has been to interface everything where possible and so features that are taken from PascalCoin/Core, from Albert Molina et al, have been re-envisioned in this framework, although the underlying code is the same. This is the same for PascalCoin KeyTools from library by Ugochukwu Mmaduekwe.

I've stuck to core Delphi where I can (I'd rather have used XSuperObject for JSON, but I have persevered with System.JSON and REST.JSON) but there are a few places where I have needed external libraries such as the crypto libraries written for PascalCoin, TFrameStand (which should be part of Delphi by now), Spring4d (although I've restricted my use of that).

The project uses Spring4Delphi container to provide Multicast events and also dependency injection, which is used in a rough and ready way, but it does give a single point to see what interfaces and classes are used and that you don't need to remember what secondary objects need to be instantiated (and of course it is simpler to provide alternatives).

There are a few external dependancies you need for to have installed:

Crypto Libraries:

SimplebaseLib4Pascal: https://github.com/Xor-el/SimpleBaseLib4Pascal
HashLib4Pascal: https://github.com/Xor-el/HashLib4Pascal
CryptoLib4Pascal: https://github.com/xor-el/cryptoLib4Pascal/

Note that if you have PascalCoin/Core installed then these can be found in the libararies sub directory.

Other external libraries needed:

FrameStand: available via GetIt package manager or at https://github.com/andrea-magni/TFrameStand
Spring4D: https://bitbucket.org/sglienke/spring4d

In the libraries sub directory:
DelphiZXingQRCode by Debenu (used for drawing the QR Code)  Apache 2 License
- original VCL source available from https://www.debenu.com/open-source/delphizxingqrcode/ the version bundled here is updated to work with FMX

ZXZing_Scanner by Edward Spelt (this will be used for QR Code scanning) updates available from https://github.com/Spelt/ZXing.Delphi/  APache 2 License

Documentation has been added using Documentation InSight from DevJet. It's easy enoungh to copy the layout required.

At the moment the testnet data for the app is held in C:\Users\<user>\AppData\Roaming\PascalCoin_URBAN you can get a quick start bu copying the contents of  C:\Users\<user>\AppData\Roaming\PascalCoin_TESTNET to C:\Users\<user>\AppData\Roaming\PascalCoin_URBAN

There is a config.inc file, but it's not used as there is only 2 possible Defines at the moment, TESTNET and PRODUCTION, so these are set in the Delphi Project Options.

Other repositories, although not needed for this project they are needed as reference points at least

PascalCoin/Core: https://github.com/PascalCoin/PascalCoin
PascalCoin/PascalCoinTools: https://github.com/PascalCoin/PascalCoinTools

Folder Structure

Utils Core : Shared interfaces, objects and functions etc
RPC Core : RPC interfaces and objects
Wallet Core : Wallet interfaces and objects
Libraries : Third party library code
Wallet UI : the wallet application
RPC Test : think of this as manual unit tests - it's where I work things out. 
Note that there is code in various interfaces/classes which is conditional upon {$DEFINE UNITTEST}. These are properties etc that make testing easier, see the Transaction Raw Op for an example.

The main form is defined in 'Wallet UI\PascalCoin.FMX.Wallet.pas'
The main datamodule is defined in 'Wallet UI\PascalCoin.FMX.DataModule.pas'

Look and Feel
==============
No images yet.

There are 2 Stylebooks - eventually they will give the light/dark options that seem to be what everyones doing these days, but for the moment they are used to give Testnet a different look to Live.

Running against TESTNET
=======================
This has only been running in Windows but I will be writign a webbroker app to enable support for remoting (from MAC OSX etc) testing. 

So just run Core TESTNET and this app on the same box and you should be fine.



if you like this you can send me donations :-)

PASC: 127501-23 (preferably) 
- but as I'm not proud:
BTC:  3GsyvoSY9EqJnW5VFhpUUhGLgKKTTsYAEQ
ETH:  0xdEf093C4121B07B9a2709E553D1f0E0a72Ef3887


KEY THINGS BEING WORKED ON
==========================
The key thing at the moment is the transaction. At the moment I get an invalid signature, so I'm either loading the wallet wrongly or reading the private key incorrectly. The transaction object passes my tests when compared to the Wiki raw transaction sample, so it must be the key I think.

Things on the List
==================
PASA Transfer
Multi Operations - in particular amalgameting PASC from different account to fund a payment
FMX version of the Daemon
Refactor the Interfaces and Objects into a better overall file structure
Change how nodes are handled (stop over reliance on RPCConfig)
Stop being lazy and convert everything to actions and not OnClicks

Thanks to:
==========

Albert for the amazing idea to do PascalCoin in the first place and the never ending effort he puts in.
Herman for driving things forward 
Ugochukwu for his work on the crypto libraries and the help he has given me.


