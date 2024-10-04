import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const StakingEtherModule = buildModule("StakingEtherModule", (m) => {

    const stake = m.contract("EtherStaking");

    return { stake };
});

export default StakingEtherModule;

