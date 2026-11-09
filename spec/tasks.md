# Implementation tasks


## Task-01 Retrieve the complaint and account information

| Field | Value |
| --- | --- |
| Requirements | FR-001, FR-003 |
| Files |   /app/complaint/model.py, /app/complaint/repository.py, /app/account/model.py, /app/account/repository.py  |

### Implementation Instructions

- Define the complaint model
- Define the account model
- Retrieve complaint information
- Retrieve account infomration
- Define eligibility reason codes. (`INVALID_COMPLAINT`, `COMPLAINT_NOT_FOUND `, `ACCOUNT_NOT_FOUND`)
- Attach where each retrieved information comes from
- Reject unsupported reason values. 


### Definition of done

- Searching up a complaint returns all its information
- Searching up an account returns all its information based on the complaint
- The results show where it was retrieved from
- Unknown complaints or accounts are stated explictly (`INVALID_COMPLAINT`, `COMPLAINT_NOT_FOUND `, `ACCOUNT_NOT_FOUND`)

### Copilot command

Implement Task-01 only. Read the specfication and implementation plans first. Access and modify only the cited files, if other files are needed to complete the task request for access first. Run the tests and document the results based on the definition of done.



## Task-02: Implement details of complaint
| Field | Value |
| --- | --- |
| Requirements | FR-002, FR-003|
|Files| app/backend/src/repository; repository tests|
### Implementation Instructions
- Define Complaint and StatusHistory files from Data Models section of spec
- Retrive information of complaint through `complaint_id` using SQL
- Follow security not found convention
### Definition of Done
- All operational facts are tested and verified to be correct
- No account data is exposed
- AC-001, AC-002 both pass
### Copilot command

Implement Task-02 only. Read the specfication and implementation plans first. Access and modify only the cited files, if other files are needed to complete the task request for access first. Run the tests and document the results based on the definition of done.


## Task-03 Retrieve the transaction information


| Field | Value |
| --- | --- |
| Requirements | FR-002, FR-003 |
| Files |   /app/transaction/model.py, /app/transaction/repository.py, |

### Implementation Instructions

- Define the transaction model
- Define eligibility reason codes. 


### Definition of Done
- AC-003 passes
- Must be read-only files and not create anything extra

### Copilot command

Implement Task-03 only. Read the specfication and implementation plans first. Access and modify only the cited files, if other files are needed to complete the task request for access first. Run the tests and document the results based on the definition of done.
