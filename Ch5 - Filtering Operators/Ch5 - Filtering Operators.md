# Ch5 - Filtering Operators
지금까지 RxSwift의 기반 지식을 정립했으니 이제는 하나씩 지식과 기술을 익힐 때이다.

이 챕터에서는 `.next` 이벤트에 붙여 제약을 줄 수 있는 RxSwift의 filtering operator에 관련하여 다룰 것이다. 이를 통해 구독자는 원하는 이벤트만을 받아 처리할 수 있다. 

## Ignoring operators

### `ignoreElements`
`ignoreElements`를 통해 모든 `.next` 이벤트들을 무시할 수 있다. 하지만 `.completed`나 `.error` 이벤트 같이 흐름을 멈추는 이벤트는 통과시킨다.

``` Swift
example(of: "ignoreElements") {
    // 1
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    // 2
    strikes
        .ignoreElements()
        .subscribe { _ in
            print("You're out!")
        }
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    
    strikes.onCompleted()
    // You're out!
}
```

strikes를 구독했지만 그 전에 `ignoreElements`로 모든 `.next` 이벤트를 무시하라고 했기 때문에 그 전까지 출력되지 않다가 `onCompleted`에 가서야 통과가 되어 출력이 되는 것을 볼 수 있다.

### `elementAt`
하지만 만약 n번째 이벤트를 무시하고 싶다면 어떻게 해야 할까? 이럴 때는 `elementAt` operator를 사용해 받고 싶은 인덱스를 전달해주면 된다. 그 외는 전부 무시한다.

``` Swift
// 1
example(of: "elementAt") {
    // 1
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    // 2
    strikes
        .elementAt(1)
        .subscribe(onNext: { _ in
            print("You're out!")
        })
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    // You're out!
    strikes.onNext("X")
}
```

위와 같이 1번째 인덱스의 이벤트만을 구독하여 처리할 수 있다.

### `filter`
위 두 operator보다 더 복잡한 필터링을 하기 위해서는 `filter` operator를 사용한다. `filter` operator는 제약을 거는 클로저를 가지며 이것이 각각의 원소를 검사한다.

``` Swift
example(of: "filter") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
        // 2
        .filter { integer in
            integer % 2 == 0
        }
        // 3
        .subscribe (onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    // 2
    // 4
    // 6
}
```

## Skipping operators
특정 이벤트들을 건너뛰고 싶을 때 사용한다. 

### `skip`
`skip` operator는 첫 번째 수부터 인자로 전달한 갯수만큼 이벤트를 무시한다.

``` Swift
example(of: "skip") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "B", "C", "D", "E", "F")
        // 2
        .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    // D
    // E
    // F
}
```

위에서는 `skip` operator의 인자로 3만큼 전달했기 때문에 처음 이벤트를 포함한 세 이벤트가 넘겨진 것을 볼 수 있다.

### `skipWhile`
`skipWhile`은 `filter`처럼 제약 조건을 주어 어떤 이벤트가 통과될지 결정할 수 있다. 하지만 **`filter`와 다른 점은 `filter`는 구독이 끝날 때까지 지속되는 반면, `skipWhile`은 통과되지 않는 이벤트가 한 번 나올 경우 더 이상 동작하지 않고 모든 이벤트를 내보낸다.**

`filter`와 반대로 true가 나오는 원소는 넘겨지고 false가 나오는 원소만 받아 처리할 수 있다.

``` Swift
example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 2, 3, 4, 4)
        // 2
        .skipWhile { integer in
            integer % 2 == 0
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    // 3
    // 4
    // 4
}
```

위의 코드를 보면 2로 나누었을 때 나머지가 0이 나오는 2는 모두 넘겨지고 3은 통과되는 것을 볼 수 있다. 4는 나머지가 0이지만 이미 한 번 3이 나왔기 때문에 더 이상 `skipWhile`이 동작하지 않는다.

지금까지는 정적인 조건만을 주어 필터링했지만 만약 동적으로 하고 싶다면 어떻게 해야할까?

### `skipUntil`
먼저 이 operator는 source observable에서 나오는 이벤트들을 trigger observable에서 이벤트가 나올 때까지 넘기는 것이다. 마찬가지로 한 번 이벤트가 넘겨지지 않으면 이후에는 동작하지 않는다.

``` Swift
example(of: "skipUntil") {
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .skipUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    subject.onNext("A")
    subject.on(.next("B"))
    
    trigger.onNext("X")
    
    subject.onNext("C")
    // C
}
```

subject는 source observable로서 먼저 전달된 A, B는 출력되지 않고 넘겨진다. 이후 trigger에서 이벤트를 방출하면 더 이상 skip되지 않고 C가 출력된다.

## Taking operators
Taking은 Skipping과 반대로 동작하는 operator이다.

### `take`
`skip`과 반대로 `take`는 첫 번째 원소부터 인자로 전달된 갯수만큼의 원소를 취한다.

``` Swift
example(of: "take") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
        // 2
        .take(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    // 1
    // 2
    // 3
}
```

### `takeWhile`
마찬가지로 `skipWhile`처럼 동작하는 operator이다. 제약을 클로저의 형태로 전달해 해당하는 원소를 가진 이벤트만을 취할 수 있다.

때때로 방출되는 원소의 인덱스를 알고 싶을 때가 있는데 이 때는 `enumerated` operator를 사용하면 방출되는 이벤트에서 인덱스와 원소를 튜플의 형태로 얻을 수 있다.

``` Swift
example(of: "takeWhile") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 2, 4, 4, 6, 6)
        // 2
        .enumerated()
        // 3
        .takeWhile { index, integer -> Bool in
            // 4
            integer % 2 == 0 && index < 3
        }
        // 5
        .map { $0.element }
        // 6
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    // 2
    // 2
    // 4
}
```

위와 같이 `enumerated`를 사용해 index를 얻어 `takeWhile`의 제약 조건에 사용할 수 있다.

### `takeUntil`
`skipUntil`과 같이 trigger observable에서 원소가 방출될 때까지만 원소를 취한다. trigger observable이 방출이 되면 

``` Swift
example(of: "takeUntil") {
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .takeUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    // 3
    subject.onNext("1")
    subject.onNext("2")
    
    trigger.onNext("X")
    
    subject.onNext("3")
}
```

###

