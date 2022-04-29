# FACAVR12R

## PROGRAM PARMS

-----------------------------------------------------------------

    1. STARTTIME I.E(040000)
    2. ENDTIME I.E(200000)
    3. WAITSECONDS I.E(1)

-----------------------------------------------------------------

## FILES

-----------------------------------------------------------------

    READONLY:
      - IMSHDRPF

    NO UPDATE READ:
     - FACVF07PF

    UPDATE:
     - FACVF08PF
     - FACVF11PF
     - AVFCODPF
  
    WRITE:

-----------------------------------------------------------------

## FILE BASED DATASTRUCTURES

-----------------------------------------------------------------

    WCODDS BASED ON AVFCODPF

-----------------------------------------------------------------

## COPYBOOKS

-----------------------------------------------------------------

    ##AUTOCOPY
    ZCH0351R
    BCBN_H
    FACVF04_H
    FACVF05_H
    FACVF08_H
    FACAVR01_H
    FACVFSMS_H
    FACAVLOG_H

-----------------------------------------------------------------

## IMPORT SOURCES

-----------------------------------------------------------------

-----------------------------------------------------------------

## PGM CALLS

-----------------------------------------------------------------

    CALL_BILL(BILLWAU01R)
    PSEND_SUSPENSION_NOTIFICATION(AVSBSNT01R)
-----------------------------------------------------------------

## PROCEDURES

---------------------------------------------------------------

    P_CRTMSG        
    P_SENDRCVMSG    
    P_PROCMSG       
    P_PROCESS       
    P_CREATEHD      
    P_LOGIN         
    P_EMAIL         
    P_LOGOFF        
    P_LOG           
---------------------------------------------------------------

## SUBROUTINES

---------------------------------------------------------------
    SR_SETFACAVR01PF99
    SR_BILLING

## LOGIC FLOW

![text](Flow.png)

## APPLICATION MAP

![text](Whole1.png)

---------------------------------------------------------------

## DIAGRAMS

:::mermaid
%%{init:{"theme":"base"}}%%
   flowchart LR

id1[[*INZSR]] --> id2[[MAIN]]
 subgraph MAIN [MAIN]
id2[[P_CRTMSG]]  --> id3[[*INLR]]
end
:::

:::mermaid

%%{init:{"theme":"default"}}%%
   flowchart LR
   subgraph P_CRTMSG [P_CRTMSG]
    A[START] -->  B{TimeValid?}
        B -- Yes --> C{PrvReqDone?}
        C -- Yes --> D
        E[End]
        subgraph SG1 [ ]
     F[[nEXT]]
    end

    subgraph getRecords [ ]
    direction RL
     D[[getRecords]]
    end
 
    B -- No --> E[End]
    C -- No then<br> 1st Sleep ----> B
    C -- No and Over <br> 50 tries --> F[[SendSMS]]
    D -- No --> B
    end   
:::

:::mermaid
%%{init:{"theme":"neutral",'themeVariables': { 'primaryColor': '#ffcccc', 'edgeLabelBackground':'#eeeee', 'tertiaryColor': '#fff0f0'}}}%%
   flowchart LR
subgraph getRecords [getRecords]
A{ReadDone?}
A -- Yes --> B{Atleast1MSG?}
A -- No --> F[[APPEND_MSG]]
B -- No --> C[SLEEP]  
B -- Yes --> D[[P_CreateHd]]
D --> E[[P_SendRcvMsg]]
E --> G[[P_ProcMsg]]
F -.-> A
C -. RETURN .-> H[[P_CRTMSG]]
end
:::

:::mermaid
%%{init:{"theme":"neutral"}}%%
   flowchart LR
subgraph P_SendRcvMsg [P_SendRcvMsg]
A{TCP_Read?}
A -- Yes --> B{*CSMOKY?}
A -. No then RETURN .-> F[[getRecords]]
B -- Yes then RETURN .-> D[[P_ProcMsg]]
B -- No --> C{INvalidAck>MAX?}
C -- Yes -->G[[ExitJob_Notify_OPS_Client]]--> E[300sec:SLEEP] --> B
C -- No --> H[15sec:SLEEP]--> B{*CSMOKY?}
end
:::

:::mermaid
%%{init:{"theme":"neutral"}}%%
   flowchart LR
subgraph P_ProcMsg [P_ProcMsg]
A[[sr_billing]] --> B[[sr_setFacavr01pf99]]
B -. RETURN .-> C[[P_CRTMSG]]
end
:::
