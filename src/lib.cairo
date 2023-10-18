mod utils;
use starknet::ContractAddress;
use starknet::ClassHash;

#[starknet::interface]
trait IWeb3MQ<TState> {
    fn register(ref self: TState) -> u256;

    // fn bind(ref self:TState, wallet_type: felt252, chain_id:felt252, wallet_address: ContractAddress, time_stamp: u64, slat: felt252, user_id: u256);

    fn follow(ref self: TState, sender: u256, target: u256, follow: bool);

    fn block(ref self: TState, sender: u256, target: u256, block: bool);

    fn set_permission(ref self:TState, user: u256, permission:u32);

    fn get_web3mq_id(self:@TState, user:ContractAddress) ->u256;

    fn check_follow(self:@TState, sender:u256, target:u256) -> bool;

    fn check_block(self:@TState, sender:u256, target:u256) -> bool;

    fn get_permission(self:@TState, user:u256) -> u32;
}

#[starknet::interface]
trait IUpgradeable<TState> {
    fn upgrade(ref self: TState, new_implementation: ClassHash);
}

#[starknet::contract]
mod Web3MQ {
    use core::debug::PrintTrait;
    use core::box::BoxTrait;
    use core::traits::Into;
    use starknet::ContractAddress;
    use starknet::ClassHash;
    use starknet::get_caller_address;
    use starknet::replace_class_syscall;
    use starknet::get_block_timestamp;
    use starknet::get_tx_info;
    use array::ArrayTrait;

    // Ownable
    use openzeppelin::access::ownable::interface::IOwnable;
    use openzeppelin::access::ownable::ownable::Ownable;

    // Upgradable
    use openzeppelin::upgrades::interface::IUpgradeable;
    use openzeppelin::upgrades::upgradeable::Upgradeable;
    // use web3mq_cairo::interface::Web3mqID;

    use web3mq_cairo::utils::bytes::{Bytes, BytesTrait};
    #[storage]
    struct Storage {
        web3mq_id: LegacyMap::<ContractAddress, u256>,

        follow: LegacyMap::<(u256, u256), bool>,
        
        block: LegacyMap::<(u256, u256), bool>,
        
        permission: LegacyMap::<u256, u32>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        UserBind:UserBind,
        Follow:Follow,
        Block:Block,
        PermissionChanged:PermissionChanged
    }

    #[derive(Drop, starknet::Event)]
    struct UserBind {
        #[key]
        user: ContractAddress,
        user_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Follow {
        #[key]
        sender: u256,
        #[key]
        target: u256,
        follow: bool
    }

    #[derive(Drop, starknet::Event)]
    struct Block {
        #[key]
        sender: u256,
        #[key]
        target: u256,
        block: bool
    }

    #[derive(Drop, starknet::Event)]
    struct PermissionChanged {
        #[key]
        user: u256,
        permission: u32
    }

    #[external(v0)]
    impl Web3mqImpl of super::IWeb3MQ<ContractState>{
        fn register(ref self: ContractState) -> u256{
            let wallet_type = 'starknet';
            let wallet_address = get_caller_address();
            let timestamp = get_block_timestamp();
            let tx_info = get_tx_info().unbox();
            let nonce = tx_info.nonce;
            let chain_id = tx_info.chain_id;
            let mut bytes: Bytes = BytesTrait::new(0, array![]);
            self.web3mq_id.read(wallet_address);
            bytes.append_felt252('WEB3MQ_USER_ID');
            bytes.append_felt252(wallet_type);
            bytes.append_felt252(chain_id);
            bytes.append_felt252(wallet_address.into());
            bytes.append_u64(timestamp);
            bytes.append_felt252(nonce);
            let user_id = bytes.keccak();
            self.web3mq_id.write(wallet_address, user_id);
            return user_id;
        }

        // fn bind(ref self: ContractState, wallet_type: felt252, chain_id:felt252, wallet_address: ContractAddress, time_stamp: u64, slat: felt252, user_id: u256){
        //     assert(wallet_address == get_caller_address(), 'only self');
        //     let mut bytes: Bytes = BytesTrait::new(0, array![]);
        //     bytes.append_felt252('WEB3MQ_USER_ID');
        //     bytes.append_felt252(wallet_type);
        //     bytes.append_felt252(chain_id);
        //     bytes.append_felt252(wallet_address.into());
        //     bytes.append_u64(time_stamp);
        //     bytes.append_felt252(slat);
        //     assert(bytes.keccak() == user_id, 'user id error');
        //     self.web3mq_id.write(wallet_address, user_id);
        // }

        fn follow(ref self: ContractState, sender: u256, target:u256, follow: bool){
            assert(sender == self.web3mq_id.read(get_caller_address()), 'only self');
            self.follow.write((sender, target), follow);
            self.emit(Follow{sender, target, follow})
        }

        fn block(ref self: ContractState, sender: u256, target: u256, block: bool){
            assert(sender == self.web3mq_id.read(get_caller_address()), 'only self');
            self.block.write((sender, target), block);
            self.emit(Block{sender, target, block})
        }
        fn set_permission(ref self :ContractState, user: u256, permission:u32){
            assert(user == self.web3mq_id.read(get_caller_address()), 'only self');
            self.permission.write(user, permission);
            self.emit(PermissionChanged{user, permission})
        }

        fn get_web3mq_id(self:@ContractState, user:ContractAddress) ->u256{
            self.web3mq_id.read(user)
        }

        fn check_follow(self:@ContractState, sender:u256, target:u256) -> bool {
            self.follow.read((sender, target))
        }

        fn check_block(self:@ContractState, sender:u256, target:u256) -> bool {
            self.block.read((sender, target))
        }

        fn get_permission(self:@ContractState, user:u256) -> u32{
            self.permission.read(user)
        }
    }

        // Upgradable

    #[external(v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, impl_hash: ClassHash) {
            // [Check] Only owner
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::InternalImpl::assert_only_owner(@unsafe_state);
            // [Effect] Upgrade
            let mut unsafe_state = Upgradeable::unsafe_new_contract_state();
            Upgradeable::InternalImpl::_upgrade(ref unsafe_state, impl_hash)
        }
    }

    // Access control

    #[external(v0)]
    impl OwnableImpl of IOwnable<ContractState> {
        fn owner(self: @ContractState) -> ContractAddress {
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::owner(@unsafe_state)
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::transfer_ownership(ref unsafe_state, new_owner)
        }

        fn renounce_ownership(ref self: ContractState) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::renounce_ownership(ref unsafe_state)
        }
    }
}