const { ethers } = require('hardhat');
const { expect } = require("chai");

describe("DaoGovernor", function () {

    let daoGovernor, dao, execution, staking
    let owner, adminOne, adminTwo, memberOne, memberTwo, other

    beforeEach(async function () {
        const [firstAccount, secondAccount, thirdAccount, fourthAccount, fifthAccount, sixthAccount] = await ethers.getSigners();
        owner = firstAccount;
        adminOne = secondAccount;
        adminTwo = thirdAccount;
        memberOne = fourthAccount;
        memberTwo = fifthAccount;
        other = sixthAccount;

        const DaoGovernor = await ethers.getContractFactory("DaoGovernor");
        daoGovernor = await DaoGovernor.deploy();

        const Staking = await ethers.getContractFactory("Staking");
        staking = await Staking.deploy();

        const Execution = await ethers.getContractFactory("Execution");
        execution = await Execution.deploy();

        const Dao = await ethers.getContractFactory("Dao");
        dao = await Dao.deploy(staking.target, execution.target);


    });

    describe("Deploy Contracts Successfully", function () {
        it("Should set the owner to the contract owner for DaoGoverner Contract", async function () {
            // const contractOwner = await daoGovernor.owner();
            expect(await daoGovernor.owner()).to.equal(owner);
        })
        it("Should mint 1 million token to the deployer's address", async function () {
            // const contractOwner = await daoGovernor.owner();
            expect((await staking.balanceOf(owner)).toString()).to.equal("1000000000000000000000000");
        })

        it("Should set the owner to the contract owner for Execution Contract", async function () {
            // const contractOwner = await daoGovernor.owner();
            expect(await execution.owner()).to.equal(owner);
        })

        it("Should set the owner to the contract owner for Dao Contract", async function () {
            // const contractOwner = await daoGovernor.owner();
            expect(await dao.owner()).to.equal(owner);
        })
    })

    describe("Test Staking Contract Functions", function () {
        it("Should stake 100 tokens", async function () {
            const stakingAmount = "100000000000000000000"
            await staking.stake(stakingAmount);
            expect(await staking.stakedValue(owner.address)).to.equal(stakingAmount);
        })

    })
})