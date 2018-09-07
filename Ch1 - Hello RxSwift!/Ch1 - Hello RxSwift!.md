# Ch1 - Hello RxSwift!
이 책의 목적은 라이브러리에 대한 탄탄한 이해를 통해 스스로 Rx의 기술들을 계속해서 익힐 수 있도록 하는것이다.

## 정의
**RxSwift**의 핵심은 당신의 코드가 새로운 데이터에 반응하고 시퀀셜하고 분리된 방법으로 처리하게 함으로써 비동기 프로그램 개발을 쉽게 하는 것이다.

## 사용하는 이유
iOS 내에서 많은 이벤트들이 **비동기적**으로 일어나기 때문에 앱의 코드가 어떠한 순서대로 실행될 지 가정을 할 수가 없다.

### Synchronous code
배열의 각각의 원소에 대해 작업하는 것은 매우 익숙한 일이다. 매우 간단하지만 다음 두 가지를 보장함으로써 견고한 로직을 이룬다.
- **동기적**(**Synchronously**)으로 동작
- 순회할 때 콜렉션이 **불변(Immutable)**

예를 들어, 이런 코드를 실행하면 다음과 같이 출력될 것이다.
``` Swift
var array = [1, 2, 3]
for number in array {
    print(number)
    array = [4, 5, 6]
}
print(array)

// 1
// 2
// 3
// [4, 5, 6]
```

즉, for 문 안에서 array에 새로운 값을 넣어줘도 for 문이 시작될 당시의 값은 변하지 않는다.

### Asynchronous code
비동기적으로 동작하기 위해 버튼을 눌렀을 때 각각의 원소에 접근한다고 하자.

``` Swift
var array = [1, 2, 3]
var currentIndex = 0

//this method is connected in IB to a button
@IBAction func printNext(_ sender: Any) {
    print(array[currentIndex])
  
    if currentIndex != array.count-1 {
        currentIndex += 1
    }
}
```
이러한 상황이라면 초기 배열의 원소들인 1, 2, 3이 출력된다고 말할 수 있을까? 그렇지 않을 것이다. 출력이 되기 전에 원소가 제거될 수도 있고 새로운 원소를 넣을 수도 있을 것이며 심지어 `currentIndex` 값을 변경할 수도 있을 것이다.

여기서 비동기적 코드의 중요한 이슈를 발견할 수 있다.
- 작업의 순서
- 공유되는 가변 값(shared mutable data)
  
다행히도, 이 부분이 RxSwift가 강점을 보이는 곳이다.

## 비동기 프로그래밍 용어

### 1. State, and specifically, shared mutable state
노트북을 예로 들어보자. 노트북을 처음 켰을 때는 동작을 잘 하지만 몇 주가 지난 뒤에는 느려지거나 원하지 않는 방식대로 동작할 때가 있다. 하드웨어나 소프트웨어는 같지만 상태는 변했다. 재시동을 하면 그제서야 이전에 그랬던 것처럼 잘 동작한다.

메모리의 데이터, 디스크에 저장된 것들 등등 모든 것들이 합쳐져 노트북의 상태가 된다.

상태를 관리하는 것, 특히 **많은 비동기적 요소들 간에 공유되는 상태를 관리하는 것**이 이 책에서 배울 중요한 이슈들 중 하나이다.

### 2. Imperative programming
*명령형 프로그래밍*은 상태를 바꾸는 명령 코드를 사용하는 프로그래밍 패러다임으로 컴퓨터가 이해하는 코드와 비슷하다. 하지만 **복잡하고 비동기적인 앱을 만들 때 명령형 코드로 짜는 것은 매우 어려운 일**이다.

### 3. Side effects
Side Effect는 **현재 흐름의 밖에서 야기하는 상태의 변화**를 의미한다. 사실, 프로그램은 side effect를 야기하는 것이 목적이다.

중요한 것은 **그러한 side effect를 일으키되 우리가 통제할 수 있어야 한다는 점**이다. 개발자는 어떤 부분의 코드가 side effect를 일으킬 지 결정할 수 있어야 한다. RxSwift는 이러한 문제들을 다룬다.

### 4. Declarative code
명령형 프로그래밍에서는 상태를 우리의 의지대로 바꾸지만 함수형 프로그래밍에서는 우리가 side effect를 일으키지 않는다. 하지만 우리가 완벽한 세상에서 살지 않기 때문에 둘 사이에서 균형을 찾는 것이 중요한데, RxSwift가 그것을 해낸다.

선언형 코드는 행동을 정의하고 RxSwift에서 관련된 이벤트가 있을 대 그것을 실행하고 함께 동작할 데이터를 내놓는다.

> 참고 링크: [명령형 프로그래밍과 함수형 프로그래밍 비교
](https://github.com/funfunStudy/study/wiki/%EB%AA%85%EB%A0%B9%ED%98%95-%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D%EA%B3%BC-%ED%95%A8%EC%88%98%ED%98%95-%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D-%EB%B9%84%EA%B5%90)

### 5. Reactive systems
Reactive 시스템은 다음과 같은 특성을 보인다.
- **Responsive**: UI를 항상 최신의 상태로 유지한다.
- **Resilien**: 각 행동이 분리되어 있고 에러 회복에 유연하다.
- **Elastic**: 코드가 lazy pull-driven collections, event throttling, resource sharing 등 다양한 작업을 처리한다.
- **Message driven**: 요소들 간 메시지 기반의 커뮤니케이션을 통해 재사용성과 분리성을 높이고 라이프 사이클과 클래스의 구현을 분리한다.

## Rx의 세 요소

### Observables
`Observable<T>` 클래스는 Rx 코드의 기반을 제공한다: 데이터 `T`의 불변하는 스냅샷을 전달하는 이벤트들의 시퀀스를 비동기적으로 제공하는 능력. 이 `Observable<T>`를 통해 옵저버는 이벤트에 대응하고 앱의 UI를 갱신한다.

`ObservableType` 프로콜은 매우 쉽다. 다음과 같은 세 유형의 `Event`를 방출한다. enum으로 되어 있다.
- A `next` event: 가장 최신인 데이터를 "담고" 있는 이벤트. 옵저버가 값을 "받는" 방법이다.
- A `completed` event: 성공과 함께 이벤트 시퀀스를 종료하는 이벤트. 성공적으로 라이프 사이클을 끝냈다는 의미이며 더 이상 이벤트를 방출하지 않는다.
- An `error` event: 에러와 함께 이벤트 시퀀스를 종료하며 더 이상 이벤트를 방출하지 않는다.

### Operators
`ObservableType`과 `Observable` 클래스는 서로 합쳐져 좀 더 복잡한 로직을 구현할 수 있는 추상적으로 분리된 비동기 작업 부분의 여러 메서드들을 포함한다. 이러한 메서드를 `Operator`라고 부른다.

이들은 서로 체이닝을 이루어 연결될 수 있으며 이를 통해 원하는 이벤트만을 구독할 수 있다.

### Schedulers
Rx 버전의 dispatch queue이다. 이벤트를 observe하여 처리를 할 때 어떠한 큐에서 스케줄러에서 할 지 특정해줄 수 있다.

## App architecture
RxSwift는 앱의 아키텍쳐를 변하게 하지 않는다. 부분부분만을 적용시킬 수 있다.

하지만 MVVM 패턴에 특히 잘 맞는데 그 이유는 ViewModel에서 `Observable<T>` 프로퍼티를 통해 View Controller의 UIKit 제어와 바인딩을 쉽게 할 수 있기 때문이다.

> 이 책은 MVC 패턴으로 써져 쉽게 이해할 수 있게 하였다.