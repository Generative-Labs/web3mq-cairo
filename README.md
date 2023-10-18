# **Web3MQ-cairo**

## **Introduction**

Web3mq-cairo is a project which is used to store and change social relations on starknet.

### **test and deploy**

This project is based on [cairo](https://github.com/starkware-libs/cairo) and [starknet-foundry](https://github.com/foundry-rs/starknet-foundry), maybe you should learn them firstly.

- test

```rust
snforge test
```

- deploy

You need to learn about [how to deploy cairo project on starknet](https://foundry-rs.github.io/starknet-foundry/starknet/index.html).

## Design

### External functions

- register

```rust
fn register(ref self: ContractState) -> u256
```

| Return Value | Type | Description |
| --- | --- | --- |
| user_id | u256 | the user id of the caller |
- follow

```rust
fn follow(ref self: ContractState, sender: u256, target:u256, follow: bool)
```

| Parameters | Type | Description |
| --- | --- | --- |
| sender | u256 | the user id of the caller |
| target | u256 | the user id of the target user |
| follow | bool | follow/ unfollow user |
- block

```rust
fn block(ref self: ContractState, sender: u256, target: u256, block: bool)
```

| Parameters | Type | Description |
| --- | --- | --- |
| sender | u256 | the user id of the caller |
| target | u256 | the user id of the target user |
| block | bool | block/ unblock user |
- set_permission

```rust
fn set_permission(ref self :ContractState, user: u256, permission:u32)
```

| Parameters | Type | Description |
| --- | --- | --- |
| user | u256 | the user id of the caller |
| permission | u32 | see the blow table |

| Permission Value | Description |
| --- | --- |
| 0 | open to all |
| 1 | allow messages from people you’ve followed |
| 2 | allow messages from people who follow you |
| 3 | allow messages from people who follow you and you’ve followed |
- get_web3mq_id

```rust
fn get_web3mq_id(self:@ContractState, user:ContractAddress) ->u256
```

| Parameters | Type | Description |
| --- | --- | --- |
| user | ContractAddress | target user address |

| Return Value | Type | Description |
| --- | --- | --- |
| user id | u256 | target user id |
- check_follow

```rust
fn check_follow(self:@ContractState, sender:u256, target:u256) -> bool
```

| Parameters | Type | Description |
| --- | --- | --- |
| sender | u256 | user id of the people who follow the target people |
| target | u256 | user id of the people who followed by the sender |

| Return Value | Type | Description |
| --- | --- | --- |
| follow | bool | follow or not follow |
- check_block

```rust
fn check_block(self:@ContractState, sender:u256, target:u256) -> bool
```

| Parameters | Type | Description |
| --- | --- | --- |
| sender | u256 | user id of the people who block the target people |
| target | u256 | user id of the people who blocked by the sender |

| Return Value | Type | Description |
| --- | --- | --- |
| block | bool | block or not block |
- get_permission

```rust
fn get_permission(self:@ContractState, user:u256) -> u32
```

| Parameters | Type | Description |
| --- | --- | --- |
| user | u256 | target user id |

| Return Value | Type | Description |
| --- | --- | --- |
| permission | u32 | see the blow table |

| Permission Value | Description |
| --- | --- |
| 0 | open to all |
| 1 | allow messages from people you’ve followed |
| 2 | allow messages from people who follow you |
| 3 | allow messages from people who follow you and you’ve followed |