use web3mq_cairo::utils::math::{u128_join};
fn u8_array_to_u256(arr: Span<u8>) -> u256 {
    assert(arr.len() == 32, 'too large');
    let mut i = 0;
    let mut high: u128 = 0;
    let mut low: u128 = 0;
    // process high
    loop {
        if i >= arr.len() {
            break ();
        }
        if i == 16 {
            break ();
        }
        high = u128_join(high, (*arr[i]).into(), 1);
        i += 1;
    };
    // process low
    loop {
        if i >= arr.len() {
            break ();
        }
        if i == 32 {
            break ();
        }
        low = u128_join(low, (*arr[i]).into(), 1);
        i += 1;
    };

    u256 { low, high }
}

fn u128_array_slice(src: @Array<u128>, mut begin: usize, end: usize) -> Array<u128> {
    let mut slice = ArrayTrait::new();
    let len = begin + end;
    loop {
        if begin >= len {
            break ();
        }
        if begin >= src.len() {
            break ();
        }

        slice.append(*src[begin]);
        begin += 1;
    };
    slice
}

fn u64_array_slice(src: @Array<u64>, mut begin: usize, end: usize) -> Array<u64> {
    let mut slice = ArrayTrait::new();
    let len = begin + end;
    loop {
        if begin >= len {
            break ();
        }
        if begin >= src.len() {
            break ();
        }

        slice.append(*src[begin]);
        begin += 1;
    };
    slice
}