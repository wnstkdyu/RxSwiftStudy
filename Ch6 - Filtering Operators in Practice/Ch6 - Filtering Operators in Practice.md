# Ch6 - Filtering Operators in Practice
Operator는 Observable 클래스의 원소들에 대해 동작하고 결과로 다시 새로운 Observable 시퀀스를 반환한다. 이것은 전에 보았듯이 **chain** operators를 가능하게 한다.

Ch4에서 사용했던 프로젝트를 다시 사용할 것이다.

## Improving the Combinestagram project

### `share`
같은 Observable을 여러 번 구독하는 것은 잘못된 결과를 가져올 수도 있다. Observable은 `subscribe`를 했을 때부터 동작하고 원소를 방출하는 lazy, pull-driven 시퀀스이다.

만약 아래와 같은 Observable이 있다고 하자.

``` Swift
let numbers = Observable<Int>.create { observer in
    let start = getStartNumber()
    observer.onNext(start)
    observer.onNext(start+1)
    observer.onNext(start+2)
    observer.onCompleted()
    return Disposables.create()
}

var start = 0
func getStartNumber() -> Int {
    start += 1
    return start
}
```

그리고 다음과 같이 구독을 한다고 해보면, 다음과 같은 결과가 출력될 것이다.
``` Swift
numbers
  .subscribe(onNext: { el in
    print("element [\(el)]")
  }, onCompleted: {
    print("-------------")
  })

element [1]
element [2]
element [3]
-------------
```

하지만 구독을 여러 번하면 다음과 같은 출력 결과를 얻게 될 것이다.
``` Swift
element [1]
element [2]
element [3]
-------------
element [2]
element [3]
element [4]
-------------
```

`subscribe`를 호출할 때마다 새로운 Observable을 생성하기 때문에 그 전과 같은 것임을 보장하지 않는다. 심지어 같은 원소의 시퀀스를 생성하더라도 각각의 구독에서 중복된 원소를 생성하는 것은 과도하다.

구독을 공유하기 위해서는 `share()` operator를 사용한다. 하나의 Observable에서 여러 시퀀스를 만들어 내고 그것을 필터링해서 처리하는 것은 Rx 코드에서 흔한 패턴이다.

`share` operator는 오직 구독자가 처음 생길 때 subcription을 생성한다. 즉, shared한 구독이 아직 없을 때 생성한다는 뜻이다. 두번째, 세번째 구독자가 생기면 `share`는 미리 만들어 둔 subscription을 통해 sequence를 제공한다. 이 shared한 시퀀스의 모든 구독이 disposed되면 `share`는 이 시퀀스를 dispose한다. 만약 다른 구독자가 구독을 시작하면, `share`는 다시 새 구독을 만들어 제공한다.

> `share`는 구독이 효력을 발휘하기 전의 방출한 값을 제공하지 않지만 `share(replay:scope:)`는 제한된 크기의 버퍼를 제공해 새 구독자에게 이전의 값을 제공할 수 있다.

### Ignoring all elements
먼저 모든 원소를 다 무시하는 filtering operator부터 보자. `ignoreElements()`를 사용한다.

`ignoreElements()`를 사용하면 값을 가지는 모든 이벤트를 무시하기 때문에 `.completed`와 `.error` 이벤트에만 집중할 수 있다.

``` Swift
newPhotos
  .ignoreElements()
  .subscribe(onCompleted: { [weak self] in
    self?.updateNavigationIcon()
  })
  .disposed(by: photosViewController.bag)
```

### Filtering elements you don't need
때로는 특정 원소만 걸러내고 싶을 때가 있다. 그 때는 `filter(_:)`를 사용한다.

``` Swift
newPhotos
  .filter { newImage in
    return newImage.size.width > newImage.size.height
  }
  [existing code .subscribe(...)]
```

### Using throttle to reduce work on subscriptions with high load
`throttle` operator를 통해 한정된 시간 동안의 빠른 입력 중 가장 나중의 것만을 취할 수 있다. 다음과 같은 예에서 유용하게 사용될 수 있다.
- 검색 textField: 현재 검색하고 싶은 단어를 서버의 API로 보내는 경우, 유저가 단어를 완성할 때가지 기다리는 것이 좀 더 효율적일 것이다.
- VC를 모달로 띄우는 경우: 유저가 탭을 하여 VC가 모달로 올라오는 경우, 두 번 올라오는 것을 방지할 수 있다.
- 터치를 드래그하다 멈추는 것을 감지할 경우
