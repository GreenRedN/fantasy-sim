# Fantasy Sim v2 (완성본)

멀티 모듈 Maven 프로젝트입니다.

- `fantasy-sim-core` : 게임 엔진/도메인/룰/더미 AI(JSON 카드 생성 + 검증 + 캐시)
- `fantasy-sim-cli`  : 터미널에서 바로 플레이
- `fantasy-sim-api`  : Spring Boot REST API (세션 생성/next/choose/환생)

## 요구 사항
- Java 21
- Maven 3.x (권장)
  - 또는 포함된 `./mvnw` 사용 가능: 첫 실행 시 Maven 3.9.6 다운로드(인터넷 필요), `curl` 또는 `wget` + `tar` 필요

## 빌드 (루트)

```bash
# 루트(fantasy-sim)에서
./mvnw test
./mvnw -DskipTests package

# Maven이 설치되어 있다면 mvn으로도 동일하게 실행 가능
# mvn test
# mvn -DskipTests package
```

## 실행 (CLI)

```bash
# 루트(fantasy-sim)에서
./mvnw -pl fantasy-sim-cli -am -DskipTests package

# NOTE: CLI는 의존성(jackson 등)을 포함한 "-all" 실행 JAR를 생성합니다.
java -jar fantasy-sim-cli/target/fantasy-sim-cli-2.1.0-all.jar
```

## 실행 (API)


```bash
# 루트(fantasy-sim)에서
./mvnw -pl fantasy-sim-api -am -DskipTests spring-boot:run
```

기본 포트: `8080`

### API 사용 예시

아래는 **세션 생성 → next(카드/자동 진행) → choose(선택 확정) → (선택) state 조회 → 엔딩 후 rebirth** 기본 흐름입니다.

0) 헬스체크

```bash
curl http://localhost:8080/api/health
```

1) 세션 생성

```bash
curl -X POST http://localhost:8080/api/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "race":"human",
    "name":"그린",
    "nameless": false,
    "seed": 12345
  }'
```

- `race`: `human | elf | beast | dwarf`
- `nameless=true`면 이름은 무시되며, **환생(rebirth) 불가** 모드로 시작합니다.
- `seed`는 선택(없으면 서버가 랜덤 생성)

응답(축약) 예시:

```json
{
  "sessionId": "0f8fad5b-d9cb-469f-a165-70867728950e",
  "world": { "...": "..." },
  "player": { "...": "..." },
  "meta": { "...": "..." }
}
```

2) 다음 턴 (카드 생성/자동 진행)

```bash
curl -X POST http://localhost:8080/api/sessions/<SESSION_ID>/next
```

- 응답 `TurnOutcome`에서 `needsChoice=true`면, `eventCard.choices[].id` 중 하나를 골라 `choose`를 호출합니다.
- `needsChoice=false`면 `autoLine` 또는 `summaryText`가 채워질 수 있고, 내부적으로는 자동 Effect가 적용될 수 있습니다.

3) 선택 확정 (YES/NO 또는 GOOD/NEUTRAL/EVIL)

```bash
curl -X POST http://localhost:8080/api/sessions/<SESSION_ID>/choose \
  -H "Content-Type: application/json" \
  -d '{ "choiceId": "YES" }'
```

- `choiceId`: `YES | NO | GOOD | NEUTRAL | EVIL`

4) 상태 조회 (현재 world/player/meta 스냅샷)

```bash
curl http://localhost:8080/api/sessions/<SESSION_ID>/state
```

5) 환생 (엔딩 이후만 가능, nameless 제외)

```bash
curl -X POST http://localhost:8080/api/sessions/<SESSION_ID>/rebirth
```

- `ended=true` 상태가 된 뒤에만 가능합니다.
- `nameless=true`로 시작한 세션은 rebirth가 막힙니다(설계/기획 규칙).

### 에러 응답 형식

API는 실패 시 다음 형식으로 응답합니다:

```json
{ "error": "BAD_REQUEST", "message": "...", "path": "/api/sessions" }
```

## 룰/설정 파일

- `fantasy-sim-core/src/main/resources/config.json`
- `fantasy-sim-core/src/main/resources/rules/effects.json`

`effects.json`은 **(turnType + tags + choiceId + 조건(worldDemonHigh 등))** 규칙을 합산 후,
난이도/턴타입 배율을 적용해서 최종 Effect를 만듭니다.


## 세계관(고유명사/세력/신앙) 데이터
- 기획서(요약/설계): `docs/planning_v1_1.md`
- `fantasy-sim-core/src/main/resources/lore/world_bible_A.json` : 고유명사/무역/신앙/마계/정치관계 등 “추가 설정”을 구조화
- 요약 문서: `docs/lore_additions_A.md` (원문: `docs/lore_additions_source.txt`)
