const {expect} = require("chai");
const { ethers } = require("hardhat");

const toWei = (num) => ethers.utils.parseEther(num.toString())
const fromWei = (num) => ethers.utils.formatEther(num)

describe('Token and Vault Contract', function() {

    let deployer, address1, address2, feeAccount

    beforeEach(async function(){
        const Token = await ethers.getContractFactory("SampleToken");
        const Vault = await ethers.getContractFactory("Vault");
        const Staking = await ethers.getContractFactory("StakingRewards");
        //Get signers
        [deployer, address1, address2, feeAccount] = await ethers.getSigners();
        //Deploy contract
        token = await Token.deploy(toWei(1000000));
        vault = await Vault.deploy("Wrapped SampleToken", "wSAM", token.address);
        staking = await Staking.deploy(token.address);
    })

    describe("Token Deployment", function(){
        it("Should deploy the contract", async function(){
            expect(token.address).to.exist;
        })
        it("Should track name and symbol of token", async function(){
            expect(await token.name()).to.equal("SampleToken");
            expect(await token.symbol()).to.equal("SAM");
        })
        it("Should track deplyer balance and total supply", async function(){
            expect(await token.balanceOf(deployer.address)).to.equal(toWei(1000000));
            expect(await token.totalSupply()).to.equal(toWei(1000000));
        })
    })
    describe("Vault Deployment", function(){
        it("Should deploy the contract, track name and symbol", async function(){
            expect(vault.address).to.exist;
            expect(await vault.name()).to.equal("Wrapped SampleToken");
            expect(await vault.symbol()).to.equal("wSAM");
        })
        it("Should have correct token address", async function(){
            expect(await vault.Token()).to.equal(token.address);
        })
        it("Should have initial token balance of 0", async function(){
            expect(await token.balanceOf(vault.address)).to.equal(0);
        })
    })
    describe("Vault Functions", function(){
        beforeEach(async function(){
            //Deposits
            await token.connect(deployer).approve(vault.address, toWei(1000000));
            await vault.connect(deployer).deposit(toWei(1000000));
        })

        it("Users should be able to deposit and withdraw tokens", async function(){
            //Checks vault token balance
            expect(await token.balanceOf(vault.address)).to.equal(toWei(1000000));
            //Checks user xToken balance
            expect(await vault.balanceOf(deployer.address)).to.equal(toWei(1000000));

            //Withdraw
            await vault.connect(deployer).approve(vault.address, toWei(1000000));
            await vault.connect(deployer).withdraw(toWei(1000000));
            expect(await token.balanceOf(vault.address)).to.equal(0);
            expect(await token.balanceOf(deployer.address)).to.equal(toWei(1000000));
            expect(await vault.balanceOf(deployer.address)).to.equal(0);
            
        })
        // it("Should payout dividends in eth based on staked token bal", async function(){
        //     //deployer transfers 30% of staked tokens to address 2
        //     await vault.connect(deployer).transfer(address2.address, toWei(300000));

        //     //Checks vault token balance
        //     expect(await token.balanceOf(vault.address)).to.equal(toWei(1000000));
        //     //checks that address 2 has 30% of staked tokens
        //     expect(await vault.balanceOf(address2.address)).to.equal(toWei(300000));
        //     // //checks that deployer has 70% of staked tokens
        //     expect(await vault.balanceOf(deployer.address)).to.equal(toWei(700000));

        //     //Address 1 transfers eth to vault contract
        //     await vault.connect(address1).depositEth({value: toWei(100)});
        //     const vaultBal = await ethers.provider.getBalance(vault.address);
        //     console.log("Valut eth bal: ", fromWei(vaultBal));


        //     const newVaultBal = await ethers.provider.getBalance(vault.address);
        //     console.log("New Valut eth bal: ", fromWei(newVaultBal));

        //     //deployer receives dividends (working)
        //     const deployerBal = await ethers.provider.getBalance(deployer.address);
        //     console.log("Deployer eth bal: ", fromWei(deployerBal))
            
        // })

    })
})