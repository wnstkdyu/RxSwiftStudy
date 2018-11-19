# Ch8 - Transforming Operators in Practice

### Using `flatMap` to wait for a web response
`flatMap`을 사용하면 두 가지 효과를 얻을 수 있다.
- Observable들을 평탄하게(flatten) 하여 안의 원소를 방출하고 complete하게 한다.
- 비동기적 요청을 하는 Observable들을 평탄하게 하여 다시 Observable을 만들어 체이닝을 이어갈 수 있게 한다.

만약 `flatMap`을 사용하지 않고 `map`을 사용할 경우에는 Observable이 중첩이 되어 복잡한 구조가 될 것이다.

#### share vs. shareReplay
`URLSession.rx.response(request:)`를 통해 request를 날리면, response를 받고, data와 함께 .next 이벤트를 방출하고 complete 이벤트를 방출하며 시퀀스는 종료된다. 이 경우 새 구독자가 생긴다면 같은 요청을 다시 한 번 보내야 하는 상황이 벌어진다. 이것을 막기 위해 `share(replay:, scope:)`를 사용한다.

이 때, 인자로 전달하는 scope에는 두 가지 종류가 있는데 각각 다음과 같다.
- `.forever`: 버퍼에 저장된 네트워크 리스폰스가 영원히 저장되어 새로운 구독자가 받을 수 있다. 물론 메모리 이슈에 주의해야 한다.
- `.whileConnected`: 버퍼에 저장된 네트워크 리스폰스가 더 이상 구독자가 없을 때까지 저장된다. 새 구독자는 새로운 네트워크 리스폰스를 받는다.