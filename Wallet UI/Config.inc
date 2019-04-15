{
  PascalCoin Copyright (c) 2016 by Albert Molina
  pascalCoin FMX (c) 2019 Russell Weetch

  Distributed under the MIT software license, see the accompanying file LICENSE
  or visit http://www.opensource.org/licenses/mit-license.php.

  This unit is a part of Pascal Coin FMX which accesses PascalCoin a P2P crypto
  currency without need of historical operations.

  ******************************************
  PascalCoin FMX configuration file to build
  ******************************************

  Compiler directives definitions:

  - TESTNET                 : Will compile a TESTNET version
  - PRODUCTION              : Will compile a PRODUCTION (Main Net) version

}

{.$DEFINE PRODUCTION}
{$DEFINE TESTNET}

{$IFDEF TESTNET}{$IFDEF PRODUCTION}
ERROR: You must select ONLY ONE option: PRODUCTION or TESTNET
{$ENDIF}{$ELSE}{$DEFINE PRODUCTION}{$ENDIF}