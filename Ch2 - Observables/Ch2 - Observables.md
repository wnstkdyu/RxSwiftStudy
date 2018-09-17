# Ch2 - Observables

## What is an observable?
`Observable`은 Rx의 핵심이다.

다음과 같은 용어들이 서로 교차되며 쓰인다.
- `Observable`
- `Observable sequence`
- `Sequence`

실제로 이 세 가지는 모두 같은 것들이다. 가끔 `Stream`이라는 용어를 사용하는 것을 볼 수 있는데 이 용어는 다른 Rx 프로그래밍 환경에서 적합하다. 하지만 RxSwift에서는 sequence로 사용한다.

Obervable은 **특별한 힘을 가진** sequence이다. 그 중 하나가 *asynchronous*이다. Observable은 이벤트를 *emitting*하는데, 각각의 이벤트는 값을 가지고 있다.

## Lifecycle of an observable
Observable은 다음과 같은 생명 주기를 가진다.
- 값을 포함한 **next** 이벤트를 방출한다. 이것은 다음 둘 중 하나가 일어날 때까지 지속된다.:
- **error** 이벤트를 방출하고 종료되거나,
- **completed** 이벤트를 방출하고 종료된다.
- Observable이 한 번 종료되면 더 이상 이벤트를 방출하지 않는다.

Observable은 enum 타입의 `Event`를 방출한다.
``` Swift
/// Represents a sequence event.
///
/// Sequence grammar: 
/// **next\* (error | completed)**
public enum Event<Element> {
    /// Next element is produced.
    case next(Element)

    /// Sequence terminated with an error.
    case error(Swift.Error)

    /// Sequence completed successfully.
    case completed
}
```

next와 error는 각각 Element, Error 타입의 값을 포함하고 있다는 것을 알 수 있다. 나중에 이 이벤트를 구독하여 값을 받아와 적절한 처리가 가능하다.

## Creating observables
Observable의 타입 메서드를 사용하여 Observable을 생성할 수 있다. 이러한 메서드들을 `operators`라고 칭한다.
- `just`: 하나의 원소를 받고 하나의 원소에 대한 Observable를 반환
- `of`: 여러 원소를 받아 하나의 원소에 대한 Observable를 반환
- `from`: 배열을 받아 하나의 원소에 대한 Observable를 반환

타입 명시를 하지 않을 경우, 타입 추론이 이루어져 적절한 타입의 Observable을 반환한다.

## Subscribing to observables
Subscribe를 하는 것은 iOS의 `NotificationCenter`와 비슷하다. 그러나 다음과 같은 차이점이 있다.
- `Notification`을 사용할 때는 `.default`를 통해 싱글턴 인스턴스를 사용하지만, Rx는 각각의 Observable이 다르다.
- 더 중요한 것은 Observable은 **subcriber가 생겨야 그제서야 이벤트를 방출한다.**

다음과 같이 subcribe 할 수 있다.
``` Swift
// 1. event 종류에 관계없이 처리할 경우
observable.subscribe { event in
    print(event)
}
// 2. event 종류에 따라 처리
observable
  .subscribe(
    onNext: { element in
      print(element)
  },
    onError: { (error) in
            print(error)
  },
    onCompleted: {
      print("Completed")
  }
)
```

## Disposing and termintating
Subscribe 메서드는 `disposable`를 반환하는데 이것을 `dispose()` 시켜야 **메모리 누수**를 방지할 수 있다. 일반적으로 `DisposeBag` 타입의 인스턴스에 `disposed(by:)` 메서드를 통해 observable를 넣어준다. `DisposeBag`의 인스턴스가 메모리에서 dealloc될 때 넣어진 observable들도 같이 dealloc시켜 준다.

## Using Traits
`Traits`는 observable보다 조금 더 제한적인 행동을 가지는 observable이다. 코드를 읽는 사람의 명확한 이해를 위해 사용한다.

- `Single`: `.success(value)`나 `.error` 이벤트를 방출하며 `success(value)` 이벤트는 `.next`와 `.completed` 이벤트를 조합한 형태이다. one-time 프로세스에 적합하며 데이터의 다운로드나 디스크 로딩에 사용된다.
- `Completable`: `.completed`나 `.error` 이벤트만을 방출하며 값을 가지지 않고 성공, 실패 여부만이 중요한 경우 사용된다. 파일 쓰기가 여기에 해당.
- `Maybe`: 위의 두 가지가 섞인 경우이다. 값을 가질 수도, 가지지 않을 수도 있을 경우에 사용한다. `.success(value)`, `.completed`, `.error` 이벤트를 방출한다.
