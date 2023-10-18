use snforge_std::{declare, ContractClassTrait, start_prank};
use web3mq_cairo::IWeb3MQSafeDispatcher;
use web3mq_cairo::IWeb3MQSafeDispatcherTrait;

use starknet::ContractAddress;
use starknet::contract_address::Felt252TryIntoContractAddress;
use snforge_std::PrintTrait;

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::new()).unwrap()
}

#[test]
fn test_register(){
    let contract_address = deploy_contract('Web3MQ');
    let safe_dispatcher = IWeb3MQSafeDispatcher { contract_address };

    // Change the caller address to 123 when calling the contract at the `contract_address` address
    let addr_1 = 0x024f4db2125B03D36C7D6ceab0e1213e30D92c4B1A71E2b10AeBFB24F2d4d0e4.try_into().unwrap();
    start_prank(contract_address, addr_1);

    safe_dispatcher.register();
}