import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "0x8Af08C1c8c4615332084694E59A36ee7d51BEAF5";

const StakingErc20Module = buildModule("StakingErc20Module", (m) => {

    const stake = m.contract("StakingErc20", [tokenAddress]);

    return { stake };
});

export default StakingErc20Module;

// Deployed ERC20: 0x8Af08C1c8c4615332084694E59A36ee7d51BEAF5
