const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DaoModule", (m) => {
    const stakingAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const executionAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const dao = m.contract("Dao", [stakingAddress, executionAddress]);

    return { dao };
});