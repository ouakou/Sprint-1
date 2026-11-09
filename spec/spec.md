## Banking complaint resolution assistant





## Objective

Help analysts manage banking complaints, support it with the correct relative information and propose the appropiate action.

## Problem Statement

Complaint systems currently rely on repeated manual checks on data and policy statements to link to the customers complaint case to determine whether to escelate or if more information is needed etc. Proposed solution covers implementing a RAG system pulling information from policy content to give deterministic services for the complaint facts of client. A controlled investigation workflow will show source of all evidence displayed to keep verified facts and human decisions sperate. This will be shown to a reviewer who can challenge and understand the proposed outcome.

## Scope

### In-scope

- Retrieveal of policy evidence.
- Access to exact strucutured records.
- Human approved outcome.
- Agent workflow.
- Check if information retrieved is missing or wrong.
- Draft a customer response.
- Audit Trail.


### Out of scope

- Unrestricted access to the database.
- Automating the response and decision process.
- Using real sensitive data.
- Retrieving any information without correct source citation.


## Personas

### Complaint Anaylyst

Goal: Investigates the complaints

Wants: Needs to Understand the complaint, verify the customer’s history, locate the applicable policy and prepare a recommendation.

Solution: The soltuion should give them a structured case view, SQL-backed facts, cited policy passages, missing-information prompts and a draft recommendation 

Pain points: Repeated manual checks thoughout the system, confused about which facts matter and when to escalate

### Supervisor/reviewer

Goal: Review any snesitie or high priority outcomes

Wants: Needs to review sensitive, uncertain or compensatory outcomes before action is taken 

Solution: The solution will provide an evidence summary, citations, reasoning trace, proposed action and approve, reject or request-changes controls .

Pain points: Difficult to challenge a request without clear facts and policy.

### Customer

Goal: To make a complaint and receive a human approved decision.

Wants: To receive a clear and accurate response 

Solution: The solution should provide a human-approved explanation and outcome; the customer does not directly operate the internal assistant.

Pain points: Not understanding why the issue happened and having to wait a long time for a response or answer.


## Pre-conditions

- PC-001: The customer already has an existing account to file the complaint


## Data Models


### Customer 

| Column | Type | Key |
|---|---|---|
| `customer_id` | str | Primary Key |
| `name` | str |  No |
| `segment` | str |  No | 

### Account

| Column | Type | Key |
|---|---|---|
| `account_id` | str | Primary Key |
| `customer_id` | str | Foreign Key (Customer) |
| `type` | str | No |
|`status` | str |  No |

### Complaint

| Column | Type | Key |
|---|---|---|
| `complaint_id` | str | Primary Key |
| `customer_id` | str | Foreign Key (Customer) |
| `account_id` | str | Foreign Key (Account)|
| `urgency` | str | No |
| `received_at` | timestamp |  No |
|`category` | str |  No |
|`Status` | str |  No |

### Transaction

| Column | Type | Key |
|---|---|---|
| `transaction_id` | str | Primary Key |
| `account_id` | str | Foreign Key (Account)|
| `type` | str |  No |
|`amount` | str | No |
|`processed_at` | date |  No |


### Desposit

| Column | Type | Key |
|---|---|---|
| `transaction_id` | str | Foreign Key (Transaction) |
| `type` | str |  No |
|`amount` | str | No |
|`posted_at` | date |  No |

### Fee

| Column | Type | Key |
|---|---|---|
| `fee_id` | str | Primary Key |
| `account_id` | str | Foreign Key (Account)|
| `type` | str |  No |
|`amount` | str | No |
|`charged_at` | date |  No |

### Service request

| Column | Type | Key |
|---|---|---|
| `request_id` | str | Primary Key |
| `account_id` | str | Foreign Key (Account)|
| `type` | str |  No |
|`status` | str | No |
|`created_at` | date |  No |


## Core flows

Happy path(s):
- Intake of all the complaint and customer data from `get_complaint` and if available is recorded as `RECEIVED`
- System classifies fee and priority of complaint is recorded as `UNDER_INVESTIGATION`
- Gather all relevant facts from account and complaint using `get_complaint` and `get_customer_account_history`
- Call RAG tool to retrieve relevant policy data (using `search_policy`)
- Check evidence to confirm nothing is required or contradictory
- Prepare a case summary that separates verified facts, retrieved policy evidence and generated analysis
- Propose next action based retrieved information
- Send proposed action to supervisor by `create_review_request`, gives status `PENDING_REVIEW`
- Reviewer approves and approval reference is recorded
- `update_case_status` called and provided with approval reference
- Draft `draft_customer_response` to give message to person
- `record_audit_event` runs at every step to record process

Decision points and alternative paths:
- At step 2: Critical or sensitive complaint route staright to supervisor
- At step 3: If complaint isn't found give status `COMPLAINT_NOT_FOUND`
- At step 4: No relevant policy passage found status `INSUFFICIENT_EVIDENCE`
- At step 4: Contradictory policy passages found status `CONTRADICTORY_EVIDENCE`
- At step 5: Required facts missing status `INCOMPLETE_EVIDENCE`
- At step 5: Contradictory narrative with facts status `CONTRADICTORY_EVIDENCE`
- At step 6: Insufficient evidence for review status `INSUFFICIENT_EVIDENCE`
- At step 7: No controlled action proposed move to step 9
- At step 8: Reviewer rejects



## Requirements

FR-001 Design must clearly separate verified facts, retrieved policy evidence, system-generated analysis and human decisions.

FR-002 The LLM must not invent or change operational facts.

FR-003 SQL is used when the answer must come from exact structured records.

FR-004 The agent shall only use the spepcifc tools provided.

FR-005 Each passage of RAG result must include the source document, section, version and effective date. If no relevant passage is found the solution must report insufficient evidence instead of inventing policy.

FR-006 Each tool should have a defined input schema, output schema, validation rules, permissions, error behaviour and audit requirements.

FR-007 Fixed workflow preferred wherever required sequence is predictable.

FR-008 Final response should explain transaction and deposit timing.

## Business rules

BR-001 A complaint that is a high proprity or a sensitive scenario is escalated to a human review (supervisor/reviewer)

BR-002 Any legal claim must be approved by a human.

BR-003 Any discretionary repayment must be approved by an authorised reviewer and recorded with supporting reason.

BR-004 A case status must not be updated without approval request.

## Contracts

### get_complaint
- Input: `complaint_id`
- Output: All complaint details, `complaint_id`, `customer_id`, `status_id`, `category`, `received_at`.
- Reason Codes: `OK`,`INVALID_COMPLAINT`,`COMPLAINT_NOT_FOUND`

### get_customer_account_history
- Input: Retrieve approved customer account and fee facts (`complaint_id`)
- Output: Returns typed structured data (`customer_id`, `account_id`, `fee_id`, `CMP-2026-0042`) from SQL
- Reason Codes: `OK`, `ACCOUNT_NOT_FOUND`, `FEES_NOT_FOUND`

### search_policy
- Input: Retrieve relevant approved policy passages
- Output: Evidence ID of passages (Passages metadata)
- Reason Codes:`OK`, `INSUFFICIENT_EVIDENCE`, `CONTRADICTORY_EVIDENCE`

### create_review_request
- Input: Proposed action, evidence ID of passages
- Output: Pending approval
- Reason Codes: `OK`, `ALREADY_PENDING`, `INSUFFICIENT_EVIDENCE`

### update_case_status
- Input: Record approved case status change
- Output: Requires valid approval request
- Reason Codes: `OK`, `NO_APPROVAL`, `INVALID_APPROVAL_REFERENCE`

### Draft_customer_response
- Input: Facts ID, Evidence ID, Valid approval reference
- Output: Draft text
- Reason Codes: `OK`, `INSUFFICIENT_EVIDENCE`
### record_audit_event
- Input: All previous tool inputs and outputs, 
- Output: Overview of which tools performed on each stage
- Reason Codes: `OK`, `INVALID_EVENT`

## Acceptance Criteria

AC-001 Complaint record correctly retrieved

- given the complaint exists
- When the analyst checks it
- Then it shows `OK`

AC-002 Complaint record incorrectly retrieved

- Given the complaint does not exist
- When the analyst checks it
- Then it shows `COMPLAINT_NOT_FOUND`


AC-003 Fee retrieved

- Given the fee exists
- When get_customer_account_history tool is called
- Then it shows the fees and `OK`

AC-004 Policy retrieved is contradictory

- Given the policy returns two opposing passages
- When `search_policy` is called
- Then it shows `CONTRADICTORY_EVIDENCE`

## Clarifications


Vague input: "High priority scenario is escalated"

Clarifacations: 

- CL-001: What is the requirements for a complaint to be a critcal priority?

Decision: Any immediate safety, active account takeover, repeated unauthorized activity, or customer unable to secure access.

- CL-002: What is the requirements for a complaint to be a priority?

Decision: Transaction amount ≥ £1000 plus an explicit unauthorized/fraud indicator.

- CL-003: What is the requirements for a complaint to be a medium priority?

Decision: Transaction amount  £250–£1000 with no critical indicator 

- CL-004: What is the requirements for a complaint to be a standard priority?

Decision: Transaction amount below £250 with no unauthorized-use, vulnerability or repeat-impact indicator.

