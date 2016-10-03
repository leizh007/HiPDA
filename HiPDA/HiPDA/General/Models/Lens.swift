//
//  Lens.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part, Whole) -> Whole
}

precedencegroup LensPrecedence {
    associativity: right
}

infix operator >>>: LensPrecedence

func >>><A, B, C>(lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return Lens(get: { rhs.get(lhs.get($0)) },
                set: { (c, a) in
                    lhs.set(rhs.set(c, lhs.get(a)), a)
    })
}
