const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("ExecutionModule", (m) => {

    const execution = m.contract("Execution");

    return { execution };
});