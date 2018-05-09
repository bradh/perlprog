/* @(#)slcnt.c	2.1 97/09/03 */

/* Copyright (C) 1997 Thomson-CSF TTM / ATGL

slcnt: outil de comptage de lignes sources.

*/

static char sccsid[] ="@(#)slcnt.c	2.2 01/10/28 Thales TRT / ATGL";

/*-------------------------------------------------------------------------
**  MODULE:             SLCNT
**
**
**  ABSTRACT:
**      This utility extracts statistitics about source code files.
**      The statistics concerns:
**         NORMAL DISPLAY:
**              - total number of lines,
**              - number of source code line,
**              - number of source code lines containing at least one statement,
**              - number of lines containing only comments,
**              - number of lines mixing source code and comments,
**         EXTENDED DISPLAY (verbose)
**              - total number of lines,
**              - number of source code line,
**              - number of source code lines containing at least one statement,
**              - number of lines containing only comments,
**              - number of lines mixing source code and comments,
**              - number of empty lines
**              - total number of characters in the file
**              - total number of characters in comments
**
**      This file may be compiled using one of the three following modes:
**
**          UNIX:
**              assuming that stat is put in a directory defined in the user's
**              PATH,
**              the syntax of the call is then (angle brackets surround optional
**              parameters):
**                  SLCNT
**                      [-v]
**                      [-132]
**                      [-e]
**                      [-p]
**                      [-l language]
**                      [-o output_file]
**                      [-c eol_terminated_comment]
**                      [-wcl]
**                      [-cs start_of_nested_comment]
**                      [-ce end_of_nested_comment]
**                      filenames
**                      [-x filenames_to_exclude]
**              * with -v providing for an extended results display (verbose)
**              * with -132 providing for a 132 columns output
**              * with -e providing for expansion of list files
**              * with -p considering command level list files as real list
**              files (otherwise they are 'pre-expanded')
**              * with language providing for the kind of language the file is
**              made of
**              * with output_file enabling to write the results in a file
**              * with eol_terminated_comment identifying a string of character
**              starting comments that are finished by an end of line
**              * with start_of_nested_comment identifying a string of character
**              starting a comment that is finished by a string defined by
**              the -ce parameter
**              * with end_of_nested_comment identifying a string of character
**              ending a comment that is opened by a string defined by
**              the -cs parameter
**              * with filenames being a space separated list of file names
**              (with possibly wild cards),
**              * with filenames_to_exclude defining a space separated list of
**              file not to process.
**
**              if a file defined in as filenames parameter has the ".LST" or
**              ".LISTE_SRC"
**              extension, it is supposed to contain a list of files to process
**              (one file name per line),
**
**
**          VMS_AS_UNIX:
**              To access the command, one must issue the following DCL
**              statement:
**                  $slcnt=="$<device of slcnt>:[<directory of slcnt>]slcnt.exe"
**              the syntax of the call is then the same as the one for UNIX
**              (see above)
**
**
**          PURE_VMS:
**              The access to the command is done through a VMS CLD interface.
**              The associated command is included below.
**
**      The chosen mode must be set with a preprocessor command
**          #define xx
**      where xx is the name of the chosen mode
**
**  AUTHORS:            S. KONC
**
**  DATE CREATION:      30/9/90
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   90/11/28
**      AUTHOR: H. Moni - S. Konc
**      RESULT VERSION: 1.1
**      DESCRIPTION:
**      Extend on line help with description of version and outputs
**      add a 132 columns output format (-132)
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   90/11/29
**      AUTHOR: H. Moni
**      RESULT VERSION: 1.1
**      DESCRIPTION:
**      Extend ".LST" and ".LISTE_SRC" are accepted as files list
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   90/12/21
**      AUTHOR: H. Moni
**      RESULT VERSION: 1.2
**      DESCRIPTION:
**      Taking into account simple quote ' with DCL,SIAM,LTR2 and LTR3 langage
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   91/1/8
**      AUTHOR: S. Konc
**      RESULT VERSION: 1.3
**      DESCRIPTION:
**      Extension for a port under MS-DOS. The variables used to count are
**      explicitly defined as "long int" rather than "int". Printing format
**      are also modified accordingly.
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   91/2/1
**      AUTHOR: S. Konc
**      RESULT VERSION: 1.4
**      DESCRIPTION:
**      casting bugs are corrected after a port on a SiliconGraphics.
**      the expressions (c being a char):
**              (c=fgetc(fd)) == EOF
**              (a char) != -1
**      are replaced with
**              (c=(char)fgetc(fd)) == (char)EOF
**              (a char) != (char)-1
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   91/7/1
**      AUTHOR: S. Konc
**      RESULT VERSION: 1.4a
**      DESCRIPTION:
**      corrects a bug in counting list files in list files
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   91/8/21
**      AUTHOR: S. Konc
**      RESULT VERSION: 1.5
**      DESCRIPTION:
**      make SLCNT lint clean
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   91/8/29
**      AUTHOR: B. Chague
**      RESULT VERSION: 1.5a
**      DESCRIPTION:
**      add comments for warning messages displayed by "lint" (SUN 4)
**      and during Borland C++ compilation (PC/DOS)
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   91/10/24
**      AUTHOR: S. Konc
**      RESULT VERSION: 1.6
**      DESCRIPTION:
**      correction of bugs:
**         - filenames in list file not correctly read for Unix
**         - contiguous list files in a list file have cumulated result
**      new features:
**         - simple support of C++
**         - 'expand' mode where list files appear only as their contents
**         - 'pure' mode where command level list files are real ones
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   91/12/4
**      AUTHOR: S. Konc
**      RESULT VERSION: 1.6a
**      DESCRIPTION:
**      correction of bugs:
**         - ignore void characters between comment separators
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   92/01/23
**      AUTHOR: B. Chague
**      RESULT VERSION: 1.6b
**      DESCRIPTION:
**      modification:
**         - supress automatic recognition of assembly language
**         - create ASMTMS language definition
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   92/06/04
**      AUTHOR: B. Chague
**      RESULT VERSION: 1.6c
**      DESCRIPTION:
**      modification:
**         - add "Thomson Sintra ASM contact"
**         - SLCNTMUL.DOC user's manual changes
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   93/11/15
**      AUTHOR: G. Cristau
**      RESULT VERSION: 1.7
**      DESCRIPTION:
**      modification:
**         - Added option for "wc -l" style option
**         - Changed Chague --> ASM as contact
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   97/08/28
**      AUTHOR: TTM / ATGL 
**      RESULT VERSION: 2.1
**      DESCRIPTION:
**      modification:
**         - Added compilation option for UNIX
**         - Simple Support for Lex & Yacc : (C rules)
**		suffixes : .l, .lex, .y 
**         - Added suffixes for C++ : .hpp, .cc, .hh, .ic 
**
**=============================================================================
**  MODIFICATION HISTORY:
**      DATE:   2001/10/28
**      AUTHOR: Christophe MARI TRT
**      RESULT VERSION: 2.2
**      DESCRIPTION:
**      modification:
**         - Added comparison mode for ClearCase
**
**=============================================================================
**--
**      ASSOCIATED COMMAND (CLD interface)
**=============================================================================
!--------------------------------------------------------------------------
! SLCNT.CLD
!--------------------------------------------------------------------------
! author:       S. Konc
! date:         05/10/90
! synopsis:
!
!       the SLCNT command extracts statistics about source code of miscellaneous
!       languages. The user interface of the command is:
!               * 1 argument (P1): file names list (with wild cards [%*])
!               * 1 qualifier (/exclude): a list of file names to exclude (i.e.
!                       not to process) (with wild-cards [%*]).
!               * 1 qualifier (/output): the name of a file where the result is
!                       to be written (default is SYS$OUTPUT)
!               * 1 qualifier (/language): a language name that is enforced for
!                       the processing of all the files
!               * 1 qualifier (/nstart): defines a string managed as the
!                       beginning of a comment block
!               * 1 qualifier (/nend): defines a string managed as the end
!                       of a comment block
!               * 1 qualifier (/estart): enables the definition of a string
!                       that starts an end of line termined comment
!                       commentaire se terminant par la fin de ligne
!               * 1 qualifier (/verbose): asks for detailed statitics
!               * 1 qualifier (/s132): prints output on a 132 columns format
!               * 1 qualifier (/expands): expand list files
!               * 1 qualifier (/pure): considering command level list files
!                       as real list files (otherwise they are 'pre-expanded')
!       Examples:
!               $ SLCNT MY_FILE.IS_BEAUTIFUL
!               $ SLCNT MY_*.*_BEAUTIFUL,*FILE.IS* /LANGUAGE=C
!               $ SLCNT/EXCLUDE=(*FILE.IS*) MY_*.*_BEAUTIFUL
!
!       To install the command type:
!               $ SET COMMAND SLCNT.CLD
!--------------------------------------------------------------------------
MODULE  SLCNT
IDENT   "V1.6c"
DEFINE  VERB    SLCNT
        IMAGE   LIBDIR:SLCNT.EXE

        PARAMETER       P1,     LABEL=$INPUT_FILES,
                                PROMPT="Files",
                                VALUE(REQUIRED, LIST, TYPE=$INFILE)
        QUALIFIER       EXCLUDE,LABEL=$EXCLUDE_FILES,
                                VALUE(LIST, TYPE=$INFILE)
        QUALIFIER       OUTPUT,LABEL=$OUTPUT_FILE,
                                VALUE(TYPE=$OUTFILE)
        QUALIFIER       LANGUAGE,LABEL=$LANGUAGE,
                                VALUE(TYPE=LANGUAGE)
        QUALIFIER       NSTART,LABEL=$NSTART,
                                VALUE(TYPE=$QUOTED_STRING)
        QUALIFIER       NEND,LABEL=$NEND,
                                VALUE(TYPE=$QUOTED_STRING)
        QUALIFIER       ESTART,LABEL=$ESTART,
                                VALUE(TYPE=$QUOTED_STRING)
        QUALIFIER       VERBOSE,LABEL=$VERBOSE
        QUALIFIERS      S132,LABEL=$S132
        QUALIFIERS      EXPAND,LABEL=$EXPAND
        QUALIFIERS      PURE,LABEL=$PURE

DEFINE TYPE     LANGUAGE
        KEYWORD ADA
        KEYWORD ASM68K
        KEYWORD ASMTMS
        KEYWORD ASSMOUF
        KEYWORD C
        KEYWORD DCL
        KEYWORD FORTRAN
        KEYWORD LTR2
        KEYWORD LTR3
        KEYWORD PASCAL
        KEYWORD UIL
        KEYWORD SIAM
        KEYWORD CPP */

/*** current version of SLCNT                                           ***/
#define VERSION         "2.2"

/** definition of the working environment                               **/
#ifndef UNIX
#ifndef PURE_VMS
#define VMS_AS_UNIX
#endif
#endif

#ifdef VMS_AS_UNIX
#define IS_VMS
#endif

#ifdef PURE_VMS
#define IS_VMS
#endif

#ifdef UNIX
#define END_OF_DIRECTORY        '/'
#endif

#ifdef IS_VMS
#define END_OF_DIRECTORY        ']'
#endif


#define SKEXTENSION

/*-------------------------------------------------------------------------
**
**  INCLUDE FILES
**
*/
#ifdef IS_VMS
#include <descrip.h>
#endif

#include <stdio.h>
#include <ctype.h>
#include <string.h>

/*-------------------------------------------------------------------------
**
**  MACRO DEFINITIONS
**
*/
/*- maximal size of a filename                                          -*/
#define MAX_FILENAME_SZ 256
/*- number of start/end of comments sequences                           -*/
#define NB_C            2

/*- identify a comment that is terminated by end of line                -*/
#define EOL_TERMINATED_COMMENT  -1

/*- identify a nested comment                                           -*/
#define NESTED_COMMENT          0

/*- identify a positional comment                                       -*/
#define POSITIONAL_COMMENT      1

#define DEFAULT_END_OF_NESTED_COMMENT   "\n"

/*- display format for results  (normal/verbose) 80/132 columns         -*/
#define WCLFORMAT       "%8d %s\n"
#define NDFORMAT        "%-20s LT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu\n"
#define CNDFORMAT       "%-20s LT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu NF:%4d\n"
#define ENDFORMAT       "%s\n                     LT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu\n"
#define ECNDFORMAT      "%s\n                     LT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu NF:%4d\n"
#define CVDFORMAT \
        "%s\nLT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu LV:%6lu CT:%6lu CC:%6lu\nNF:%4d\n"
#define VDFORMAT \
        "%s\nLT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu LV:%6lu CT:%6lu CC:%6lu\n"

#define NDFORMAT132     "%-72s LT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu\n"
#define CNDFORMAT132    "%-72s LT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu NF:%4d\n"
#define CVDFORMAT132 \
        "%-42s LT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu LV:%6lu CT:%6lu CC:%6lu NF:%4d\n"
#define VDFORMAT132 \
        "%-42s LT:%6lu LS:%6lu LI:%6lu LC:%6lu LM:%6lu LV:%6lu CT:%6lu CC:%6lu\n"

/*- logical names for languages descriptions                            -*/
#define C       0       /*- identify C language descriptor              -*/
#define ADA     1       /*- identify ADA language descriptor            -*/
#define PASCAL  2       /*- identify PASCAL language descriptor         -*/
#define FORTRAN 3       /*- identify FORTRAN language descriptor        -*/
#define ASSMOUF 4       /*- identify mouflon assembly language descriptor-*/
#define ASM68K  5       /*- identify 68k assembly language descriptor   -*/
#define DCL     6       /*- identify VMS DCL                            -*/
#define UIL     7       /*- identify DECWindows UIL                     -*/
#define SIAM    8       /*- identify SIAM                               -*/
#define LTR2    9       /*- identify LTR2                               -*/
#define LTR3    10      /*- identify LTR3                               -*/
#define C_PLUS_PLUS 11  /*- 1.5: identify C++                           -*/
#define ASMTMS  12      /*- identify TMS assembly language descriptor   -*/

#define COMMANDE_COMPARE	"lcount"	/*- nom de la commande utilisee pour faire la comparaison -*/

/*- logical access to the patterns list of the file to process          -*/
/*- create a new entry in the list                                      -*/
#define NEW_FILE_DESC   ((FILE_DESC *)malloc(sizeof(FILE_DESC)))
/*- initialize an entry in the list                                     -*/
#ifdef PURE_VMS
#define INIT_FILE_DESC(e,w)\
        e->descrip.dsc$w_length=w.dsc$w_length,\
        e->descrip.dsc$b_dtype = DSC$K_DTYPE_T,\
        e->descrip.dsc$b_class = DSC$K_CLASS_S,\
        e->descrip.dsc$a_pointer = &(e->name),\
        e->type = 0,\
        e->next = NULL,strcpy(e->name,w.dsc$a_pointer)
#endif
#ifdef VMS_AS_UNIX
#define INIT_FILE_DESC(e,w)\
        e->descrip.dsc$w_length=strlen(w),\
        e->descrip.dsc$b_dtype = DSC$K_DTYPE_T,\
        e->descrip.dsc$b_class = DSC$K_CLASS_S,\
        e->descrip.dsc$a_pointer = &(e->name),\
        e->type = 0,\
        e->next = NULL,strcpy(e->name,w)
#endif
#ifdef UNIX
#define INIT_FILE_DESC(e,w)\
        e->type = 0,\
        e->next = NULL,strcpy(e->name,w)
#endif
/*- initialize an entry in the list (when the entry comes from a list)  -*/
#ifdef IS_VMS
#define INIT_LIST_DESC(e,w,l)\
        e->descrip.dsc$w_length=strlen(w),\
        e->descrip.dsc$b_dtype = DSC$K_DTYPE_T,\
        e->descrip.dsc$b_class = DSC$K_CLASS_S,\
        e->descrip.dsc$a_pointer = &(e->name),\
        e->type = l,\
        e->next = NULL,strcpy(e->name,w)
#endif
#ifdef UNIX
#define INIT_LIST_DESC(e,w,l)\
        e->type = l,\
        e->next = NULL,strcpy(e->name,w)
#endif
/*- get the first entry of the list                                     -*/
#define FIRST_FILE_DESC first_file_desc
/*- get the next entry in the list                                      -*/
#define NEXT_FILE_DESC(e)       e->next

/*- logical access to the exclusion patterns list                       -*/
/*- create a new entry in the list                                      -*/
#define NEW_EXCLUDE_DESC        ((EXCLUDE_DESC *)malloc(sizeof(EXCLUDE_DESC)))
/*- initialize an entry in the list                                     -*/
#ifdef PURE_VMS
#define INIT_EXCLUDE_DESC(e,w)\
        e->descrip.dsc$w_length=w.dsc$w_length,\
        e->descrip.dsc$b_dtype = DSC$K_DTYPE_T,\
        e->descrip.dsc$b_class = DSC$K_CLASS_S,\
        e->descrip.dsc$a_pointer = &(e->name),\
        e->next = NULL,strcpy(e->name,w.dsc$a_pointer)
#endif
#ifdef VMS_AS_UNIX
#define INIT_EXCLUDE_DESC(e,w)\
        e->descrip.dsc$w_length=strlen(w),\
        e->descrip.dsc$b_dtype = DSC$K_DTYPE_T,\
        e->descrip.dsc$b_class = DSC$K_CLASS_S,\
        e->descrip.dsc$a_pointer = &(e->name),\
        e->next = NULL,strcpy(e->name,w)
#endif
#ifdef UNIX
#define INIT_EXCLUDE_DESC(e,w)\
        e->next = NULL,strcpy(e->name,w)
#endif
/*- get the first entry of the list                                     -*/
#define FIRST_EXCLUDE_DESC      first_exclude_desc
/*- get the next entry in the list                                      -*/
#define NEXT_EXCLUDE_DESC(e)    e->next

/*- percentage of f for e                                               -*/
#define PERCENT(e,f) ((e==0)?0:(int)((float)f*100.0/(float)e))

/*- the extension for list files                                        -*/
#ifdef UNIX
#define LIST_EXTENSION1 "lst"   /*1.5: unix is case sensitive, others are not */
#define LIST_EXTENSION2 "liste_src"
#else
#define LIST_EXTENSION1 "LST"
#define LIST_EXTENSION2 "LISTE_SRC"
#endif

#define RESET_CUMUL \
            cur_line_number =\
            cur_char_number =\
            cur_char_in_cmt =\
            cur_cmt_lines =\
            cur_pcmt_lines =\
            cur_code_lines =\
            cur_code_stats =\
            cur_void_lines = 0,\
            filenb=0;

#define ACCUMULATE \
            tot_line_number += cur_line_number,\
            tot_char_number += cur_char_number,\
            tot_char_in_cmt += cur_char_in_cmt,\
            tot_cmt_lines += cur_cmt_lines,\
            tot_pcmt_lines += cur_pcmt_lines,\
            tot_code_lines += cur_code_lines,\
            tot_code_stats += cur_code_stats,\
            tot_void_lines += cur_void_lines

/*- normalize (to upper) a character before matching it with comments   -*/
#define NORM_CHAR(c)    (isalpha(c) ? (islower(c) ? toupper(c) : c) : c)

/*- behaviour when asking for next character                            -*/
#define ACCEPT_VOID 0
#define IGNORE_VOID 1

/*- for debugging purpose
#define TRACE
-*/

/*-------------------------------------------------------------------------
**
**  EXPORTED VARIABLES
**
*/

/*-------------------------------------------------------------------------
**
**  IMPORTED VARIABLES
**
*/
/*--- functions ---*/
extern char *malloc(/* size */);

#ifndef UNIX 	/*- 2.1 -*/
extern char *strncpy(/* char *to, char *from, int size */); 
extern char *strcpy(/* char *to, char *from */); */
#endif 		/*- 2.1 -*/

/*--- values    ---*/

/*-------------------------------------------------------------------------
**
**  LOCAL VARIABLES
**
*/
/*--- structures ---*/
/*- define the "TOKEN" type                                             -*/
typedef enum {
        EOL_TK,
        EOF_TK,
        EOS_TK,
        STRING_SEP,
        CHAR_SEP,
        COMMENT_S,
        COMMENT_E,
        OTHER
} TOKEN;

/*- formal description to be able to parse a language                   -*/
typedef struct {
        char    eol;            /*- end of line                 -*/
        char    *voidc;         /*- void characters (word sep.) -*/
        char    *eos;           /*- end of statement            -*/
        char    *soc;           /*- level 1 comment
                                   (for eol terminated comments)-*/
/*-ACHTUNG! it simply will not work for strings longer than 80 !-*/
        char    *start_c[NB_C]; /*- start of comment            -*/
        char    *end_c[NB_C];   /*- end of comment (not eol)    -*/
        int     in_comment;     /*- nested comments? 0:no, 1:yes-*/
        char    *pos_c[NB_C];   /*- start of positional comment -*/
        int     position[NB_C]; /*- position of positional      -*/
                                /*- comment (1: 1st column)     -*/
        char    char_id;        /*- character identifier        -*/
        char    string_sep;     /*- string separator            -*/
        char    string_esc;     /*- string escape character     -*/
} CODEDESC;

/*- define the structure associating a formal language description      -*/
/*-     with file extensions (for automatic recognition of language)    -*/
typedef struct {
        char *ext;              /*- extension value             -*/
        char *name;             /*- language name               -*/
        int  language;          /*- language description        -*/
} CODEEXT;

/*- files to be processed are managed as a list of patterns, FILE_DESC  -*/
/*- describe an element of such a list                                  -*/
#ifdef IS_VMS
typedef struct s_file_desc {
        struct  dsc$descriptor_s descrip;       /*- pattern descriptor  -*/
        char    name[MAX_FILENAME_SZ];          /*- pattern value       -*/
        int     type;
          /*- type -4 => to be ignored                                  -*
           *- type -3 => a .lst included in a not command level .lst    -*
           *- type -2 => a .lst included in a command level .lst        -*
           *- type -1 => a command level .lst                           -*
           *- type 0 => a file to count that is either a parameter of   -*
           *- the command or included in a command level .lst           -*
           *- type > 0 => a file to count that is defined in a non      -*
           *- command level .lst                                        -*/
        struct  s_file_desc *next;              /*- points to next element-*/
} FILE_DESC;
#else
/*- UNIX -*/
typedef struct s_file_desc{
        char    name[MAX_FILENAME_SZ];          /*- pattern value       -*/
        int     type;
          /*- type -4 => to be ignored                                  -*
           *- type -3 => a .lst included in a not command level .lst    -*
           *- type -2 => a .lst included in a .lst                      -*
           *- type -1 => a command level .lst                           -*
           *- type 0 => a file to count that is either a parameter of   -*
           *- the command or included in a command level .lst           -*
           *- type > 0 => a file to count that is defined in a non      -*
           *- command level .lst                                   -*/
        struct s_file_desc *next;               /*- points to next element-*/
} FILE_DESC;
#endif

/*- exclusion files are managed as a list of patterns, EXCLUDE_DESC     -*/
/*- describe an element of such a list                                  -*/
#ifdef IS_VMS
typedef struct s_exclude_desc{
        struct dsc$descriptor_s descrip;        /*- pattern descriptor  -*/
        char    name[MAX_FILENAME_SZ];          /*- pattern value       -*/
        struct s_exclude_desc *next;            /*- points to next element-*/
} EXCLUDE_DESC;
#else
/*- UNIX -*/
typedef struct s_exclude_desc{
        char    name[MAX_FILENAME_SZ];          /*- pattern value       -*/
        struct s_exclude_desc *next;            /*- points to next element-*/
} EXCLUDE_DESC;
#endif

/*--- functions (CC on SUN does not accept prototypes                   ---*/
void    get_args        (/* int argc, char **argv               */);
int     set_language    (/* char *fn                            */);
FILE_DESC *expand_list  (/* FILE_DESC *f,int level              */);
int     scan            (/* char *fn                            */);
char    get_next_char   (/* FILE *fd, int behavior              */);
void    unget_char      (/* char c                              */);
void push_char          (/* char c                              */);
void reset_char         ();
char pop_char           ();
TOKEN   get_next_token  (/* FILE *fd                            */);
void    unget_token     (/* TOKEN t                             */);
void    get_comment     (/* FILE *fd,int level,int first_line   */);
void    get_string      (/* FILE *fd                            */);
void    get_char        (/* FILE *fd                            */);
void    print_result    (/* char *filename,int cumul            */);
void    print_result_wcl(/* char *filename,int cumul            */);
void    print_usage     ();
void    print_error     (/* char *pattern,char *arg1,char *arg2 */);

/*--- values    ---*/

/*- formal description of languages                                     -*/
static CODEDESC table_desc[] = {
        /*- describe C                  -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                ";",            /*- eos                         -*/
                NULL,           /*- soc                         -*/
                {"/*",NULL},    /*- start of comment            -*/
                {"*/",NULL},    /*- end of comment              -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                '\'',           /*- character identifier        -*/
                '"',            /*- string separator            -*/
                '\\'            /*- string escape               -*/
        },
        /*- describe ADA                                        -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                ";",            /*- eos                         -*/
                "--" ,          /*- soc                         -*/
                {NULL,NULL},    /*- start of comment            -*/
                {NULL,NULL},    /*- it's eol                    -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},                /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '"',            /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        },
        /*- describe PASCAL                                     -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                ";",            /*- eos                         -*/
                NULL,           /*- soc                         -*/
                {"{","(*"},     /*- start of comment            -*/
                {"}","*)"},     /*- end of comment              -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '\'',           /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        },
        /*- describe FORTRAN                                    -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                NULL,           /*- eos                         -*/
                "!",            /*- soc                         -*/
                {NULL,NULL},    /*- start of comment            -*/
                {NULL,NULL},    /*- end of comment              -*/
                0,              /*- comments not nested         -*/
                {"C","*"},      /*- pos_c positional comments   -*/
                {1,1},          /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '\'',           /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        },
        /*- describe ASSMOUF                                    -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                ";",            /*- eos                         -*/
                "!" ,           /*- soc                         -*/
                {NULL,NULL},    /*- start of comment            -*/
                {NULL,NULL},    /*- it's eol                    -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '"',            /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        },
        /*- describe ASM68K                                     -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                NULL,           /*- eos                         -*/
                "*",            /*- soc                         -*/
                {NULL,NULL},    /*- start of comment            -*/
                {NULL,NULL},    /*- it's eol                    -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '"',            /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        },
        /*- describe VMS DCL                                    -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f$",       /*- void char                   -*/
                NULL,           /*- eos                         -*/
                "!",            /*- soc                         -*/
                {NULL,NULL},    /*- start of comment            -*/
                {NULL,NULL},    /*- it's eol                    -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '"',            /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        },
        /*- describe DECWindows UIL                             -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                ";",            /*- eos                         -*/
                "!",            /*- soc                         -*/
                {"/*",NULL},    /*- start of comment            -*/
                {"*/",NULL},    /*- end of comment              -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                '\'',           /*- character identifier        -*/
                '"',            /*- string separator            -*/
                '\\'            /*- string escape (no use)      -*/
        },
        /*- describe SIAM                                       -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                ";",            /*- eos                         -*/
                "%" ,           /*- soc                         -*/
                {NULL,NULL},    /*- start of comment            -*/
                {NULL,NULL},    /*- it's eol                    -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '"',            /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        },
        /*- describe LTR2                                       -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                ";",            /*- eos                         -*/
                NULL ,          /*- soc                         -*/
                {"COMMENT","@"},/*- start of comment            -*/
                {";",";"},      /*- it's eol                    -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '"',            /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        },
        /*- describe LTR3                                       -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                ";",            /*- eos                         -*/
                "%" ,           /*- soc                         -*/
                {NULL,NULL},    /*- start of comment            -*/
                {NULL,NULL},    /*- it's eol                    -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '"',            /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        },
        /*- 1.5 describe C++                    -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                ";",            /*- eos                         -*/
                "//",           /*- soc                         -*/
                {"/*",NULL},    /*- start of comment            -*/
                {"*/",NULL},    /*- end of comment              -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                '\'',           /*- character identifier        -*/
                '"',            /*- string separator            -*/
                '\\'            /*- string escape               -*/
        },
        /*- describe ASMTMS                                     -*/
        {
                '\n' ,          /*- eol                         -*/
                " \t\f",        /*- void char                   -*/
                NULL,           /*- eos                         -*/
                ";",            /*- soc                         -*/
                {NULL,NULL},    /*- start of comment            -*/
                {NULL,NULL},    /*- it's eol                    -*/
                0,              /*- comments not nested         -*/
                {NULL,NULL},    /*- pos_c positional comments   -*/
                {-1,-1},        /*- position: of positional comm-*/
                -1,             /*- character identifier        -*/
                '"',            /*- string separator            -*/
                -1              /*- string escape (no use)      -*/
        }
};

/*- formal description of command given rules                           -*/
static CODEDESC rule_desc = {
        '\n' ,                  /*- eol                         -*/
        " \t\f",                /*- void char                   -*/
        NULL,                   /*- eos                         -*/
        NULL,                   /*- soc(not for all C compilers)-*/
        {NULL,NULL},            /*- start of comment            -*/
        {NULL,NULL},            /*- end of comment              -*/
        0,                      /*- comments not nested         -*/
        {NULL,NULL},            /*- pos_c positional comments   -*/
        {-1,-1},                /*- position: of positional comm-*/
        -1,                     /*- character identifier        -*/
        -1,                     /*- string separator            -*/
        -1                      /*- string escape               -*/
};

/*- defines the association "file extension" , "language name",         -*/
/*- "language description"                                              -*/
static CODEEXT table_ext[] = {
        { "C", "C", C},
        { "H", "C", C},
        { "L","LEX", C },	     /*-2.1-*/
        { "LEX","LEX", C },	     /*-2.1-*/
        { "Y","YACC", C },           /*-2.1-*/
        { "ADA", "ADA", ADA },
        { "A", "ADA", ADA },
        { "PAS", "PASCAL", PASCAL },
        { "P", "PASCAL", PASCAL },
        { "FOR", "FORTRAN", FORTRAN },
        { "F", "FORTRAN", FORTRAN },
        { "CALC", "ASSMOUF", ASSMOUF },
        { "SPOR", "ASSMOUF", ASSMOUF },
        { "PERM", "ASSMOUF", ASSMOUF },
        { "INTI", "ASSMOUF", ASSMOUF },
        { "INTO", "ASSMOUF", ASSMOUF },
        { "COM", "DCL", DCL },
        { "CLD", "DCL", DCL },
        { "UIL", "UIL", UIL },
        { "SIAM","SIAM", SIAM },
        { "LTR2","LTR2", LTR2 },
        { "TR","LTR3", LTR3 },
        { "CPP","C++", C_PLUS_PLUS }, /*-2.1-*/
        { "CC","C++", C_PLUS_PLUS },  /*-2.1-*/
        { "HPP","C++", C_PLUS_PLUS }, /*-2.1-*/
        { "HH","C++", C_PLUS_PLUS },  /*-2.1-*/
        { "IC","C++", C_PLUS_PLUS },  /*-2.1-*/
        { "_%*!","ASM68K",ASM68K },   /*- supress automatic recognition     -*/
        { "_%!*","ASMTMS",ASMTMS }    /*- of 68K and TMS assembly languages -*/
};                                    /*- "_%*!" extension beeing unusable  -*/

/*- points to the obliged language formal description  and name         -*/
/*- by default deals with DCL source                                    -*/
static CODEDESC *forced_t_desc = NULL;
static char *forced_t_name = NULL;

/*- points to the current language formal description  and name         -*/
/*- by default deals with DCL source                                    -*/
static CODEDESC *t_desc = &(table_desc[DCL]);
static char *t_name = NULL;

/*- store the current file statistics values                            -*/
static unsigned long int  cur_line_number;
static unsigned long int  cur_char_number;
static unsigned long int  cur_char_in_cmt;
static unsigned long int  cur_cmt_lines;        /*- comment             -*/
static unsigned long int  cur_pcmt_lines;       /*- pure comment        -*/
static unsigned long int  cur_code_stats;
static unsigned long int  cur_code_lines;
static unsigned long int  cur_void_lines;

/*- store the accumulated statistics values                             -*/
static unsigned long int  tot_line_number = 0;
static unsigned long int  tot_char_number = 0;
static unsigned long int  tot_char_in_cmt = 0;
static unsigned long int  tot_cmt_lines = 0;
static unsigned long int  tot_pcmt_lines = 0;   /*- pure comment        -*/
static unsigned long int  tot_code_stats = 0;
static unsigned long int  tot_code_lines = 0;
static unsigned long int  tot_void_lines = 0;

/*- description of the parser current state                             -*/
static unsigned int is_void_line = 1;   /*is current line up to now void?    -*/
static unsigned int is_cmt_line = 0;    /*is the current line a comment line?-*/
static unsigned int is_in_cmt = 0;      /*is the current char in a comment   -*/
static unsigned int has_comment_line =0;/*tell if if already has comment     -*/
static unsigned int has_inst_line = 0;  /*tell if if already has instruction -*/

/*- arguments management                                                -*/
static char filename[MAX_FILENAME_SZ];  /* current argument file name   -*/
static char estart_comment[10];         /*command defin. of eol term. comment-*/
static char nstart_comment[10];         /*command def. of start nested comment*/
static char nend_comment[10];           /*command defin. of end nested comment*/

#ifdef IS_VMS
static char pattern[MAX_FILENAME_SZ];   /* current argument file pattern-*/

static char excl_filename[MAX_FILENAME_SZ];     /*cur exclusion file name-*/
static char excl_pattern[MAX_FILENAME_SZ];      /*cur exclusion file pattern -*/
static char output_filename[MAX_FILENAME_SZ];   /*output file name-*/
static char file_lang[32];              /*command level definiti. of language-*/

static $DESCRIPTOR(fn_desc,filename);
static $DESCRIPTOR(pat_desc,pattern);
static $DESCRIPTOR(excl_fn_desc,excl_filename);
static $DESCRIPTOR(excl_pat_desc,excl_pattern);
static $DESCRIPTOR(output_desc,output_filename);
static $DESCRIPTOR(fl_desc,file_lang);
static $DESCRIPTOR(es_desc,estart_comment);
static $DESCRIPTOR(ns_desc,nstart_comment);
static $DESCRIPTOR(ne_desc,nend_comment);
#endif

#ifdef PURE_VMS

#define ARG_NAME        "$INPUT_FILES"
static $DESCRIPTOR(arg_desc,ARG_NAME);  /* descriptor for the argument name-*/

#define EXCL_ARG_NAME   "$EXCLUDE_FILES"
static $DESCRIPTOR(excl_arg_desc,EXCL_ARG_NAME);/*descriptor for the exclusion*/
                                                /* qualifier                  */

#define OUTP_ARG_NAME   "$OUTPUT_FILE"
static $DESCRIPTOR(outp_arg_desc,OUTP_ARG_NAME);/*descriptor for the type     */
                                                /* qualifier                  */

#define LANG_ARG_NAME   "$LANGUAGE"
static $DESCRIPTOR(lang_arg_desc,LANG_ARG_NAME);/*descriptor for the language */
                                                /* qualifier                  */

#define NSTART_ARG_NAME "$NSTART"
static $DESCRIPTOR(nstart_arg_desc,NSTART_ARG_NAME);/*descriptor for start of */
                                                /* nested comment qualifier   */

#define NEND_ARG_NAME   "$NEND"
static $DESCRIPTOR(nend_arg_desc,NEND_ARG_NAME);/*descriptor for end of       */
                                                /* nested comment qualifier   */

#define ESTART_ARG_NAME "$ESTART"
static $DESCRIPTOR(estart_arg_desc,ESTART_ARG_NAME);/*descriptor for start of */
                                                /* eol term. comment qualifier*/

#define VERB_ARG_NAME   "$VERBOSE"
static $DESCRIPTOR(verb_arg_desc,VERB_ARG_NAME);/*descriptor for the verbose  */
                                                /* qualifier                  */

#define S132_ARG_NAME   "$S132"
static $DESCRIPTOR(s132_arg_desc,S132_ARG_NAME);/*descriptor for the s132  */
                                                /* qualifier                  */

#define EXPAND_ARG_NAME "$EXPAND"
static $DESCRIPTOR(expand_arg_desc,EXPAND_ARG_NAME);/*descriptor for the */
                                                /* expand qualifier           */

#define PURE_ARG_NAME   "$PURE"
static $DESCRIPTOR(pure_arg_desc,PURE_ARG_NAME);/*descriptor for the */
                                                /* pure qualifier             */
#endif

/*- points to the first element of the pattern lists                    -*/
static FILE_DESC *first_file_desc = NULL;
static EXCLUDE_DESC *first_exclude_desc = NULL;

/*- flags for the output format                                         -*/
static int is_verbose = 0;
static int is_s132 = 0;
static int is_pure = 0;
static int is_expand = 0;
static int is_wcl_style = 0;

/*- tell if the language is defined at the comment call                 -*/
static int is_language_defined = 0;

/*- tell if the language is defined at the comment call                 -*/
static int are_rules_defined = 0;

/*- tell whether to consider command defined rules                      -*/
static int look_alternate_rules = 0;

static int filectr = 0;         /*- counts the number of files processed-*/
static int use_escape = 0;      /*- consider string escape char ?       -*/
static int comment_family;      /*- for nested comments, describe the   -*/
                                /*- kind of comment that matches        -*/
static int comment_rank;        /*- rank of comment descriptor          -*/
/*- fichier de sortie                                                   -*/
static FILE *outfile;
/*- current column in line                                              -*/
static int col_in_line = 0;
/*- return code                                                         -*/
static int global_return =0;
/*- just to keep lint quiet                                             -*/
static int dummy =0;
/*
** ROUTINE:     main
**
** FUNCTIONAL DESCRIPTION:
**      .build the list of the file to process and exclusion patterns
**      .loop on argument files patterns
**      ..loop on files matching the patterns and not excluded
**      ...analyse the file
**      ...print results
**      .print accumulated results
**
** INPUT PARAMETERS:
**      -
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      prints results on sys$output
*/
main(argc, argv)
int argc;
char **argv;
{
#ifdef IS_VMS
   unsigned long int context, excl_context;
   int a_file_was_found;        /*- for VMS, flag to know if a pattern  -*
                                 *- succeded                            -*/
#endif
   FILE_DESC *last_file;        /*-descr of the current file to process -*/
   EXCLUDE_DESC *last_excl;     /*-descr of the current file to exclude -*/
   int filenb;                  /*- count the cumulated files number    -*/
   int filepr = 0;              /*- count the printed files number      -*/
   char *cumul_file = NULL;             /*- name of the current .lst file       -*/
   int ignore_file;             /*- flag to ignore a file               -*/

   /*- get command level arguments                                      -*/
   get_args(argc,argv);

   RESET_CUMUL;

   /*- loop on the argument patterns                                    -*/
   for (last_file=FIRST_FILE_DESC;
        last_file;
        last_file=NEXT_FILE_DESC(last_file)) {

     /*- loop on the files matching the patterns                        -*/
#ifdef IS_VMS
     context = 0;
     a_file_was_found = 0;
     while (LIB$FIND_FILE(&(last_file->descrip),&fn_desc,&context) & 1) {
        a_file_was_found = 1;
        excl_context = 0;
#else
     /*- for unix, there is no need for expanding patterns              -*/
     if (1) {
#endif
        /*- check if the file is not excluded                           -*/
        ignore_file = 0;

        /*- for all the exclusion patterns                              -*/
        for (   last_excl=FIRST_EXCLUDE_DESC;
                last_excl;
                last_excl=NEXT_EXCLUDE_DESC(last_excl)){
          /*- get all the files matching the exclusion patterns         -*/
#ifdef IS_VMS
          while(LIB$FIND_FILE(&(last_excl->descrip),
                              &excl_fn_desc,
                              &excl_context) & 1) {
                /*- does the current file match the exclusion pattern?  -*/
                if (STR$COMPARE(&excl_fn_desc,&fn_desc) == 0) {
                        ignore_file = 1;
                        break;
                }
          }
#else
          /*- for unix (could be optimised by sorting entries !)        -*/
          if (strcmp(last_excl->name,last_file->name) == 0) {
            ignore_file = 1;
            break;
          }
#endif
        }

        /*- if the current file is not excluded                         -*/
#ifdef UNIX
        /*- for compatibility reasons                                   -*/
        strcpy(filename,last_file->name);
#endif
        if (! ignore_file) {
/* printf("processing file %s type %d\n",
        last_file->name ? last_file->name : "NULL", last_file->type);
        */

         switch(last_file->type) {
          /*- type -4 => to be ignored                                  -*/
          case -4:      break;
          /*- type -3 => a .lst included in a not top level a .lst      -*/
          case -3:
                        break;
          /*- type -2 => a .lst included in a top level a .lst             -*/
          case -2:      if ((! is_pure) && (! is_expand)) {
                            if (cumul_file && (! is_expand)) {
                                print_result(cumul_file,filenb);
                                filepr++;
                                ACCUMULATE;
                                RESET_CUMUL;
                            }
                            cumul_file = last_file->name;
                        }
                        break;
          /*- type -1 => a command level .lst                           -*/
          case -1:      if (cumul_file && (! is_expand)) {
                            print_result(cumul_file,filenb);
                            filepr++;
                            ACCUMULATE;
                            RESET_CUMUL;
                        }
                        if ((is_pure) && (! is_expand))
                           cumul_file = last_file->name;
                        break;
          /*- type 0 => a file to count that is a parameter of          -*
           *- the command                                               -*/
          case 0:       if (cumul_file && (! is_expand)) {
                            print_result(cumul_file,filenb);
                            filepr++;
                            ACCUMULATE;
                            RESET_CUMUL;
                            cumul_file = NULL;
                        }
                        if (scan (filename)) {
                            /*- accumulate results                      -*/
                            print_result(filename,-1);
                            ACCUMULATE;
                            RESET_CUMUL;
                            filepr++;
                            /*- keep the file count up to date  -*/
                            filectr++;
                        }
                        break;
          /*- type 1 => a file in a command level list file             -*/
          case 1:       if (is_pure) {          /* do not show it explicitly */
                          if (scan(filename)) {
                             if (is_expand) {
                                print_result(filename,-1);
                                filepr++;
                                /*- accumulate results                  -*/
                                ACCUMULATE;
                                RESET_CUMUL;
                             }
                             filenb++;
                             filectr++;
                          }
                        }
                        else {
                          if (cumul_file && (! is_expand)) {
                            print_result(cumul_file,filenb);
                            filepr++;
                            ACCUMULATE;
                            RESET_CUMUL;
                            cumul_file = NULL;
                          }
                          if (scan (filename)) {
                            /*- accumulate results                      -*/
                            print_result(filename,-1);
                            ACCUMULATE;
                            RESET_CUMUL;
                            /*- keep the file count up to date  -*/
                            filepr++;
                            filectr++;
                          }
                        }
                        break;
          /*- type > 1 => a file to count that is defined in a non      -*
           *- command level .lst                                        -*/
          default:      if (scan(filename)) {
                           if (is_expand) {
                                print_result(filename,-1);
                                filepr++;
                                /*- accumulate results                  -*/
                                ACCUMULATE;
                                RESET_CUMUL;
                           }
                           filenb++;
                           filectr++;
                        }
                        break;
         }
        }
     }

#ifdef IS_VMS
     if (! a_file_was_found) {
        print_error("%s: can't open\n",last_file->name,(char *)0);
     }
#endif
   }

   /*- outputs cumuls results                                           -*/
   /*- modif v1.4a -*/
   if (! is_expand) {
        if (cumul_file) {
           print_result(cumul_file,filenb);
           filepr++;
        }
        ACCUMULATE;
   }

   /*- if there was more than 1 file, it makes sense to print totals    -*/
   if (filepr != 1) {
      print_result((char *)NULL,filectr);
   }

   /*- close output file                                                -*/
   if (outfile != stdout)
        dummy = fclose(outfile);

#ifdef IS_VMS
   exit(global_return);
#else
   return(global_return);
#endif
}
/*
** ROUTINE:     get_args
**
** FUNCTIONAL DESCRIPTION:
**      according to the current environment, extract the arguments
**      to the command:
**          - the files to process
**          - the files to exclude
**          - the flags (verbose,s132,expand,pure)
**          - the rules describing comments
**
** INPUT PARAMETERS:
**      argc    : number of arguments to the command line
**      argv    : array of pointers to the actual arguments
**
**      PURE_VMS mode: fetches the VMS "ARG_NAME" parameter and
**              a set of qualifiers qualifier
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
*/
void get_args(argc,argv)
int argc;
char **argv;
{
   FILE_DESC *last_file;
   EXCLUDE_DESC *last_excl;
   register int i,j;

#ifndef PURE_VMS
   int is_file = 1;
   int is_exclude = 0;
   int is_output = 0;
   int is_lang = 0;
   int is_nstart = 0;
   int is_nend = 0;
   int is_estart = 0;
   int is_compare_mode = 0 ;
#endif

   /*- init args with default values                                    -*/
   outfile = stdout;

#ifdef PURE_VMS

   /*- build the file to process pattern list                           -*/
   while(CLI$GET_VALUE(&arg_desc,&pat_desc) & 1) {
        if (FIRST_FILE_DESC == NULL) {
                FIRST_FILE_DESC = NEW_FILE_DESC;
                INIT_FILE_DESC(FIRST_FILE_DESC,pat_desc);
                last_file = FIRST_FILE_DESC;
        }
        else {
                NEXT_FILE_DESC(last_file) = NEW_FILE_DESC;
                INIT_FILE_DESC(NEXT_FILE_DESC(last_file),pat_desc);
                last_file = NEXT_FILE_DESC(last_file);
        }
        last_file = expand_list(last_file,0);
   }

   /*- build the exclusion pattern list                                 -*/
   while(CLI$GET_VALUE(&excl_arg_desc,&excl_pat_desc) & 1) {
        if (FIRST_EXCLUDE_DESC == NULL) {
                FIRST_EXCLUDE_DESC = NEW_EXCLUDE_DESC;
                INIT_EXCLUDE_DESC(FIRST_EXCLUDE_DESC,excl_pat_desc);
                last_excl = FIRST_EXCLUDE_DESC;
        }
        else {
                NEXT_EXCLUDE_DESC(last_excl) = NEW_EXCLUDE_DESC;
                INIT_EXCLUDE_DESC(NEXT_EXCLUDE_DESC(last_excl),excl_pat_desc);
                last_excl = NEXT_EXCLUDE_DESC(last_excl);
        }
   }

   /*- get the type                                                     -*/
   if (CLI$GET_VALUE(&lang_arg_desc,&fl_desc) & 1) {
          for (i=0; i < sizeof(file_lang); i++)
                if (file_lang[i] == ' ') {
                        file_lang[i] = '\0';
                        break;
                }
          /*- try against all the known types                           -*/
          for (j = 0; j < (sizeof(table_ext)/sizeof(CODEEXT)); j++) {
                if (strcmp(file_lang,table_ext[j].name) == 0) {
                        /*- if matches, init language description and name-*/
                        forced_t_desc = &(table_desc[table_ext[j].language]);
                        forced_t_name = table_ext[j].name;
                        is_language_defined = 1;
                        break;
                }
          }
          /*- if the language is unknown                                -*/
          if (forced_t_desc == NULL) {
                print_error("%s: unknown language\n",file_lang,(char *)0);
                exit(global_return);
          }
   }

   /*- get the output                                                   -*/
   if (CLI$GET_VALUE(&outp_arg_desc,&output_desc) & 1) {
          for (i=0; i < sizeof(output_filename); i++)
                if (output_filename[i] == ' ') {
                        output_filename[i] = '\0';
                        break;
                }
          if (outfile == stdout) {
                if ((outfile = fopen(output_filename,"w")) == NULL) {
                      print_error("%s: can't open\n",output_filename,(char *)0);
                      outfile = stdout;
                }
          }
   }

   /*- get the oel terminated start of comment                          -*/
   if (CLI$GET_VALUE(&estart_arg_desc,&es_desc) & 1) {
          /*- remove the double quotes                                  -*/
          register char *p = estart_comment;

          if (*p == '"') {
            for (p++; *p != '"'; p++)
                *(p - 1) = *p;
            p--;
          }
          else
            for (; *p != ' '; p++);
          *p = '\0';
          rule_desc.soc = &estart_comment;
          are_rules_defined = 1;
   }

   /*- get the nested start of comment                                  -*/
   if (CLI$GET_VALUE(&nstart_arg_desc,&ns_desc) & 1) {
          /*- remove the double quotes                                  -*/
          register char *p = nstart_comment;

          if (*p == '"') {
            for (p++; *p != '"'; p++)
                *(p - 1) = *p;
            p--;
          }
          else
            for (; *p != ' '; p++);
          *p = '\0';
          rule_desc.start_c[0] = &nstart_comment;
          if (rule_desc.end_c[0] == NULL)
                rule_desc.end_c[0] = &DEFAULT_END_OF_NESTED_COMMENT;
          are_rules_defined = 1;
   }

   /*- get the nested end of comment                                    -*/
   if (CLI$GET_VALUE(&nend_arg_desc,&ne_desc) & 1) {
          /*- remove the double quotes                                  -*/
          register char *p = nend_comment;

          if (*p == '"') {
            for (p++; *p != '"'; p++)
                *(p - 1) = *p;
            p--;
          }
          else
            for (; *p != ' '; p++);
          *p = '\0';
          rule_desc.end_c[0] = &nend_comment;
   }

   /*- look at the verbose flag                                         -*/
   if (CLI$PRESENT(&verb_arg_desc) & 1) {
        is_verbose = 1;
   }

   /*- look at the s132 flag                                            -*/
   if (CLI$PRESENT(&s132_arg_desc) & 1) {
        is_s132 = 1;
   }

   /*- look at the expand flag                                          -*/
   if (CLI$PRESENT(&expand_arg_desc) & 1) {
        is_expand = 1;
   }
   /*- look at the expand flag                                          -*/
   if (CLI$PRESENT(&pure_arg_desc) & 1) {
        is_pure = 1;
   }
#else
/*- i.e
 VMS_AS_UNIX
 UNIX
-*/
   /*- without arguments, print usage                                   -*/
   if (argc == 1) {
        print_usage();
        exit(1);
   }

   for (i = 1; i < argc; i++) {
        if (strcmp(argv[i],"-x") == 0) {
          is_exclude = 1;
          is_file = 0;
          continue;
        }

        if (strcmp(argv[i],"-l") == 0) {
          is_exclude =
                is_file = 0;
          is_lang = 1;
          continue;
        }

        if (strcmp(argv[i],"-v") == 0) {
          is_verbose = 1;
          continue;
        }

        if (strcmp(argv[i],"-132") == 0) {
          is_s132 = 1;
          continue;
        }

        if (strcmp(argv[i],"-p") == 0) {
          is_pure = 1;
          continue;
        }

        if (strcmp(argv[i],"-e") == 0) {
          is_expand = 1;
          continue;
        }

        if (strcmp(argv[i],"-o") == 0) {
          is_exclude =
                is_file = 0;
          is_output = 1;
          continue;
        }

        if (strcmp(argv[i],"-c") == 0) {
          is_exclude =
                is_file = 0;
          is_estart = 1;
          continue;
        }

        if (strcmp(argv[i],"-cs") == 0) {
          is_exclude =
                is_file = 0;
          is_nstart = 1;
          continue;
        }

        if (strcmp(argv[i],"-ce") == 0) {
          is_exclude =
                is_file = 0;
          is_nend = 1;
          continue;
        }

        if (strcmp(argv[i],"-wcl") == 0) {
          is_wcl_style = 1;
          continue;
        }

        if (strcmp(argv[i],"-comp") == 0) {
          is_compare_mode = 1 ;
          continue ;
        }

	if (is_compare_mode) {
	  char label1[100] ;
	  char label2[100] ;
	  char commande[1000] ;
	  int retour_appel ;

	  strcpy(label1,argv[i]) ;
	  strcpy(label2,argv[i+1]) ;
	  
	  sprintf(commande, \
		  "slcnt.pl %s %s %s", \
		  FIRST_FILE_DESC->name, \
		  label1, \
		  label2) ;
	  retour_appel = system(commande) ;
	  exit(retour_appel) ;
	}

        if (is_file) {
          if (FIRST_FILE_DESC == NULL) {
                FIRST_FILE_DESC = NEW_FILE_DESC;
                /*  Yes! there is a possible pointer alignment
                    problem in the previous statement ("lint" warning) */
                INIT_FILE_DESC(FIRST_FILE_DESC,argv[i]);
                last_file = FIRST_FILE_DESC;
          }
          else {
                NEXT_FILE_DESC(last_file) = NEW_FILE_DESC;
                /*  Yes! there is a possible pointer alignment
                    problem in the previous statement ("lint" warning) */
                INIT_FILE_DESC(NEXT_FILE_DESC(last_file),argv[i]);
                last_file = NEXT_FILE_DESC(last_file);
          }
          last_file = expand_list(last_file,0);
          continue;
        }

        if (is_exclude) {
          if (FIRST_EXCLUDE_DESC == NULL) {
                FIRST_EXCLUDE_DESC = NEW_EXCLUDE_DESC;
                /*  Yes! there is a possible pointer alignment
                    problem in the previous statement ("lint" warning) */
                INIT_EXCLUDE_DESC(FIRST_EXCLUDE_DESC,argv[i]);
                last_excl = FIRST_EXCLUDE_DESC;
          }
          else {
                NEXT_EXCLUDE_DESC(last_excl) = NEW_EXCLUDE_DESC;
                /*  Yes! there is a possible pointer alignment
                    problem in the previous statement ("lint" warning) */ /* Yes! there is a possible alignment problem ("lint" warning) */
                INIT_EXCLUDE_DESC(NEXT_EXCLUDE_DESC(last_excl),argv[i]);
                last_excl = NEXT_EXCLUDE_DESC(last_excl);
          }
          continue;
        }

        if (is_lang) {
          register char *p = argv[i];
          for (; *p ; p++)
             if (islower(*p))
                *p = toupper(*p);

          /*- try against all the known types                           -*/
          for (j = 0; j < (sizeof(table_ext)/sizeof(CODEEXT)); j++) {

/* printf ("argv[i]=%s, table_ext[%d]=%s\n", argv[i], j, table_ext[j].name); */

                if (strcmp(argv[i],table_ext[j].name) == 0) {
                        /*- if matches, init language description and name-*/
                        forced_t_desc = &(table_desc[table_ext[j].language]);
                        forced_t_name = table_ext[j].name;
                        is_language_defined = 1;
                        break;
                }
          }
          /*- if the language is unknown                                -*/
          if (forced_t_desc == NULL) {
                print_error("%s: unknown language\n",argv[i],(char *)0);
                exit(global_return);
          }
          /*- from now on, it is again file to process names            -*/
          is_lang = 0;
          is_file = 1;
          continue;
        }

        if (is_output) {
          if (outfile == stdout) {
                if ((outfile = fopen(argv[i],"w")) == NULL) {
                        print_error("%s: can't open\n",argv[i],(char *)0);
                        outfile = stdout;
                }
          }
          /*- from now on, it is again file to process names            -*/
          is_output = 0;
          is_file = 1;
          continue;
        }

        if (is_estart) {
          strncpy(estart_comment,argv[i],sizeof(estart_comment));
          rule_desc.soc = estart_comment;
          are_rules_defined = 1;
          /*- from now on, it is again file to process names            -*/
          is_estart = 0;
          is_file = 1;
          continue;
        }

        if (is_nstart) {
          strncpy(nstart_comment,argv[i],sizeof(nstart_comment));
          rule_desc.start_c[0] = nstart_comment;
          if (rule_desc.end_c[0] == NULL)
                rule_desc.end_c[0] = DEFAULT_END_OF_NESTED_COMMENT;
          are_rules_defined = 1;
          /*- from now on, it is again file to process names            -*/
          is_nstart = 0;
          is_file = 1;
          continue;
        }

        if (is_nend) {
          strncpy(nend_comment,argv[i],sizeof(nend_comment));
          rule_desc.end_c[0] = nend_comment;
          /*- from now on, it is again file to process names            -*/
          is_nend = 0;
          is_file = 1;
          continue;
        }
   }

#ifdef UNIX
   /*- if the input stream is a pipe, read filenames on it              -*/
   /*- don't know how to manage it !!
   if (isapipe(stdin)) {
        while(fscanf(stdin,"%s",filename) != EOF) {
          if (FIRST_FILE_DESC == NULL) {
                FIRST_FILE_DESC = NEW_FILE_DESC;
                INIT_FILE_DESC(FIRST_FILE_DESC,filename);
                last_file = FIRST_FILE_DESC;
          }
          else {
                NEXT_FILE_DESC(last_file) = NEW_FILE_DESC;
                INIT_FILE_DESC(NEXT_FILE_DESC(last_file),filename);
                last_file = NEXT_FILE_DESC(last_file);
          }
          last_file = expand_list(last_file,0);
        }
   }
   -*/
#endif /* UNIX */
#endif
   /*- some consistency rules, SKEXTENSION enables to look at the extension */

  if ((rule_desc.end_c[0] != NULL) && (rule_desc.start_c[0] == NULL)) {
    print_error("%s: define the start of comment matching '%s'\n",
                        argv[0],rule_desc.end_c[0]);
    exit(global_return);
  }
#ifndef SKEXTENSION
  if ((is_language_defined == 0) && (are_rules_defined == 0)) {
    print_error("%s: define either the language or rules to apply\n",
                argv[0],(char *)0);
    exit(global_return);
  }
#endif /* SKEXTENSION */
}
/*
** ROUTINE:     expand_list
**
** FUNCTIONAL DESCRIPTION:
**      if a file name is recognized as a list of file names, expand its
**      contents
**
** INPUT PARAMETERS:
**      f       : current descriptor of the files to process
**      level   : depth in the recursive process
**
** OUTPUT PARAMETERS:
**      returns the current descriptor of the files to process
**
** SIDE EFFECTS:
*/

/*- current list file pointer                                           -*/
static FILE *list_file = NULL;

FILE_DESC *expand_list(f,level)
FILE_DESC *f;
int level;
{
        auto char buffn[MAX_FILENAME_SZ];
        register char *p,*pf;
        FILE_DESC *local_f = f;
#ifdef IS_VMS
        register int i;
#endif

        f->type = level;

        /*- copy filename to buffln and put a '\0' at the end of fn     -*/
        for(pf=f->name,p=buffn;(*pf) && (*pf != ' ') && (*pf != ';');pf++,p++)
        /* 1.5 start */
#ifdef IS_VMS
                *p = (isalpha(*pf)) ? toupper(*pf) : *pf;
#else
                *p = *pf;
#endif
        /* 1.5 end */
        *p = '\0';

        /*- look for a '.' and recognize the extension                  -*/
        for( p-- ; (p >= buffn) && (*p != '.') ; p--);

        /*- if there is a non empty extension                           -*/
        if (*p == '.') {
          if (! *(++p)) return(f);
          /*- is it a list extension ?                                  -*/
          if ((strcmp(p,LIST_EXTENSION1) == 0) ||
              (strcmp(p,LIST_EXTENSION2) == 0)) {
#ifdef IS_VMS
            int context = 0;
            $DESCRIPTOR(buf_desc,buffn);

            while (LIB$FIND_FILE(&(f->descrip),&buf_desc,&context) & 1) {
                FILE *sav_file = list_file;
                int i;

                /*- put as ASCIZ                                        -*/
                for(i=0; i < buf_desc.dsc$w_length ;i++)
                  if (buffn[i] == ' ')
                        break;

                buffn[i] = '\0';
#else
            if (1) {
                FILE *sav_file = list_file;
#endif
                /*- modif 1.4a -*/
                if ((list_file = fopen(buffn,"r")) == NULL)
                  print_error("%s: can't open\n",buffn,(char *)0); /* 1.5 */
                else while (fscanf(list_file,"%s",buffn) != EOF) {
                        NEXT_FILE_DESC(local_f) = NEW_FILE_DESC;
                        /*  Yes! there is a possible pointer alignment
                            problem in the previous statement ("lint" warning) */
                        INIT_LIST_DESC(NEXT_FILE_DESC(local_f),buffn,level);
                        local_f = NEXT_FILE_DESC(local_f);
                        local_f = expand_list(local_f,level+1);
                }
                dummy = fclose(list_file);
                list_file = sav_file;
            }
            /*-is it a file whose result is to be printed or just accumulated-*/
            if (level > 1)
                f->type = -3;
            else if (level == 1)
                f->type = -2;
            else
                f->type = -1;
          }
        }
        return(local_f);
}
/*
** ROUTINE:     set language
**
** FUNCTIONAL DESCRIPTION:
**      extract the current file extension and set the language type
**      accordingly.
**
** INPUT PARAMETERS:
**      fn      : current file name
**
** OUTPUT PARAMETERS:
**      returns 1 if a language is set, retunrs 0 otherwise
**
** SIDE EFFECTS:
**      set the formal language description (t_desc) and name (t_name)
**      put an '\0' at the end of the current file name
*/
int set_language(fn)
char *fn;
{
        char buffn[MAX_FILENAME_SZ];
        register char *p,*pf;
        register int i,found;

        /*- copy filename to buffln and put a '\0' at the end of fn     -*/
	/*- and modify filename in upper case -*/
        for (pf = fn, p = buffn; (*pf) && (*pf != ' '); pf++,p++)
                *p = (isalpha(*pf)) ? toupper(*pf) : *pf;
        *pf = *p = '\0';

        /*- if language is obliged, job is done                         -*/
        if (is_language_defined) {
                t_desc = forced_t_desc;
                t_name = forced_t_name;
                look_alternate_rules = are_rules_defined;
                return(1);
        }
        else {
                t_desc = &rule_desc;
                t_name = NULL;
                look_alternate_rules = 0;
        }

#ifdef SKEXTENSION
        /*- look at the extension to determine description to use       -*/

        /*- ignore version in buffn                                     -*/
        for (p = buffn ; (*p) && (*p != ';') ; p++);
        *p = '\0';

        /*- look for a '.' and recognize the extension                  -*/
        for( p-- ; (p >= buffn) && (*p != '.') ; p--);

        found = 0;
        /*- if there is a non empty extension                           -*/
        if (*p == '.') {
          if (*(++p)) {
            /*- try against all the known extensions                    -*/
            for (i = 0; i < (sizeof(table_ext)/sizeof(CODEEXT)); i++) {

/* printf ("p=%s, table_ext[%d]=%s\n", p, i, table_ext[i]); */

                if (strcmp(p,table_ext[i].ext) == 0) {
                        /*- if matches, init language description and name-*/
                        t_desc = &(table_desc[table_ext[i].language]);
                        t_name = table_ext[i].name;
                        found++;
                        break;
                }
            }
          }
        }
        if (found) {
                look_alternate_rules = are_rules_defined;
        }
        else if (! are_rules_defined) {
                /*- don't known which description to use                -*/
                return(0);
        }

#endif /* SKEXTENSION */
        return(1);
}
/*
** ROUTINE:     scan
**
** FUNCTIONAL DESCRIPTION:
**      high level file scanning
**      .open the current file name
**      .init the language descriptor
**      .loop on the tokens
**      .close the file
**
** INPUT PARAMETERS:
**      fn      : current file name
**
** OUTPUT PARAMETERS:
**      returns:
**              0: if the file is not accessible
**              1: all is ok
**
** SIDE EFFECTS:
**      -
*/
int scan(fn)
char *fn;
{
        register FILE *fd;
        register TOKEN tok;
        unsigned long int sav_cur_code_lines = cur_code_lines;

        /*- set the language descriptor according to the extension      -*/
        if (! set_language(fn)) {
                print_error("%s: unable to find language\n",fn,(char *)0);
                return(0);
        }

        /*- open the current file                                       -*/
        if ((fd = fopen(fn,"r")) == NULL) {
                print_error("%s: can't open\n",fn,(char *)0);
                return(0);
        }

        /*- loop on the token (while not end of file)                   -*/
        while ((tok = get_next_token(fd)) != EOF_TK) {
          switch(tok) {
                /*- end of sentences token                              -*/
                case EOS_TK:    if (! has_inst_line) {
                                  /*- only one instruction per line is  -*
                                   *- counted                           -*/
                                  cur_code_stats++;
                                  has_inst_line = 1;
                                }
                                is_void_line = 0;
                                break;
                /*- end of line token                                   -*/
                case EOL_TK:    cur_code_lines++;
                                /*- special case EOL could be also an EOS -*/
                                if (t_desc->eos) {
                                  if (t_desc->eol == (*t_desc->eos))
                                        cur_code_stats++;
                                }
                                is_void_line = 1;
                                break;
                /*- string separator token                              -*/
                case STRING_SEP:get_string(fd);
                                break;
                /*- character delimiter token                           -*/
                case CHAR_SEP:  get_char(fd);
                                break;
                /*- start of comment token                              -*/
                case COMMENT_S: is_in_cmt = 1;
                                get_comment(fd,0,1);
                                is_in_cmt = 0;
                                break;
                default:        is_void_line = 0;
          }
        }
        /*- if there is no statement defined, statement = code line     -*/
        if (t_desc->eos == NULL)
          cur_code_stats += (cur_code_lines - sav_cur_code_lines);

        dummy = fclose(fd);
        return(1);
}
/*
** ROUTINE:     get_comment
**
** FUNCTIONAL DESCRIPTION:
**      read tokens until the matching end of comment is recognized
**
** INPUT PARAMETERS:
**      fd:             current file descriptor
**      level:          current comment level (for nested comments)
**      first_line:     tell if it is the first line of a groupe of comment
**                      lines (0: no, 1: yes)
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      eat tokens
*/
void get_comment(fd,level,first_line)
FILE *fd;
int level;
int first_line;
{
        register TOKEN tok;
        auto int family = comment_family; /*- for nested comments, store-*/
                                          /*- the matching comment kind -*/
        auto int rank = comment_rank;     /*- for nested comments, store-*/
                                          /*- the matching comment rank -*/
        register int encore = 1;

        /*- 1st level of comment, check if it is possibly a pure comment line-*/
        if (level == 0)
          is_cmt_line = (is_void_line) ? 1 : 0;
        is_void_line = 0;

        /*- loop for ever                                               -*/
        while (encore)
          switch(tok = get_next_token(fd)) {
                /*- is next token an END OF FILE                        -*/
                case EOF_TK:
                        if (family == NESTED_COMMENT)
                         print_error("%s: end of comment not found\n",filename,
                                (char *)0);
                        /*- let the upper level manage it               -*/
                        unget_token(tok);
                        encore = 0;
                break;
                case EOS_TK:
                /*- special hook for LTR2, end of statement may be as   -*
                 *- well an end of comment                              -*/
                        if (family == NESTED_COMMENT) {
                          if (rank < 0) {       /* commande level definition */
                            if (strcmp(t_desc->eos,rule_desc.end_c[0]) == 0) {
                                comment_family = family;
                                comment_rank = rank;
                                unget_token(COMMENT_E);
                            }
                          }
                          else {
                            if (strcmp(t_desc->eos,t_desc->end_c[rank]) == 0) {
                                comment_family = family;
                                comment_rank = rank;
                                unget_token(COMMENT_E);
                            }
                          }
                        }
                break;
                /*- is next token an END OF LINE                        -*/
                case EOL_TK:
                        cur_cmt_lines++;        /*- inc comment line counter -*/
                        if (is_cmt_line) {      /*- possibly line of comment?-*/
                          cur_pcmt_lines++;     /*- inc pure comment line ctr-*/
                          /*- if End of Line = End Of comment, job is done   -*/
                          if (family != NESTED_COMMENT) {
                                is_void_line = 1;
                                return;
                          }
                        }
                        else {
                          /*- the line contained also something not a comment-*/
                          /*- if End of Line = End Of comment, job is done   -*/
                          if (family != NESTED_COMMENT) {
                                /*- give a chance to the upper level         -*/
                                unget_token(tok);
                                return;
                          }
                          /*- for the first line, don't forget it is also a  -*/
                          /*- code line                                      -*/
                          if (first_line) {
                                cur_code_lines++;
                                first_line = 0;
                          }
                          /*- from now on it is possibly a pure comment line -*/
                          is_cmt_line = 1;
                        }
                break;
                /*- is next token an Start of comment                   -*/
                case COMMENT_S:
                        /*- if nested comments, recursive call to match -*/
                        /*-ignore eol terminated comments inside comments-*/
                        if ((t_desc->in_comment) &&
                            (comment_family == NESTED_COMMENT))
                          get_comment(fd,++level,first_line);
                break;
                /*- is next token an End of comment                     -*/
                case COMMENT_E:
                        /*- if comments are nested, and kind is bad, ignore -*/
                        if ((t_desc->in_comment) &&
                         ((family != comment_family) || (rank != comment_rank)))
                                continue;
                        /*- if next token is start of comment, ignore both   -*
                         *- end of comment and start of comment              -*/
                        is_in_cmt = 0;
                        if ((tok = get_next_token(fd)) == COMMENT_S) {
                                is_in_cmt = 1;
                                continue;
                        }
                        else
                                unget_token(tok);
                        is_in_cmt = 1;

                        is_void_line = 0;
                        if (level == 0) {
                          if (! has_comment_line) {
                            has_comment_line = 1;  /*- mark the line as      -*
                                                    *- holding a comment     -*/
                          /*-it may be a pure comment line if followed by EOL-*/
                            cur_cmt_lines++;
                            if (is_cmt_line) {
                              if ((tok = get_next_token(fd)) == EOL_TK) {
                                cur_pcmt_lines++;
                                is_void_line = 1;
                              }
                              else unget_token(tok);
                            }
                          }
                        }
                        encore = 0;
                break;
          }
}
/*
** ROUTINE:     get_char
**
** FUNCTIONAL DESCRIPTION:
**      read tokens until matching an end of character definition.
**      That is useful to ignore characters being string delimitors.
**
** INPUT PARAMETERS:
**      fd:             current file descriptor
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      eat tokens
*/
void get_char(fd)
FILE *fd;
{
        register TOKEN tok;

        is_void_line = 0;       /*- line is no more void                -*/
        use_escape = 1;         /*- consider string escape character    -*/
        /*- loop until encountering an Character delimitor character    -*/
        while((tok = get_next_token(fd)) != CHAR_SEP)
          switch(tok) {
                /*-is next token an End of File,let the upper level manage it-*/
                case EOF_TK:    print_error("%s: end of character not found\n",
                                                filename,(char *)0);
                                unget_token(tok);
                                return;
                                break;
                /*- is next token an End of Line                        -*/
                case EOL_TK:    cur_code_lines++;
                                break;
          }
        use_escape = 0;         /*- no more consider string escape char -*/
}
/*
** ROUTINE:     get_string
**
** FUNCTIONAL DESCRIPTION:
**      read tokens until matching an end of string definition.
**      That is useful to ignore characters being comment delimitors.
**
** INPUT PARAMETERS:
**      fd:             current file descriptor
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      eat tokens
*/
void get_string(fd)
FILE *fd;
{
        register TOKEN tok;

        is_void_line = 0;       /*- line is no more void                -*/
        use_escape = 1;         /*- consider string escape character    -*/
        /*- loop until encountering a String delimitor character        -*/
        while((tok = get_next_token(fd)) != STRING_SEP)
          switch(tok) {
                /*-is next token an End of File,let the upper level manage it-*/
                case EOF_TK:    print_error("%s: end of string not found\n",
                                                filename,(char *)0);
                                unget_token(tok);
                                return;
                                break;
                /*- is next token an End of Line                        -*/
                case EOL_TK:    cur_code_lines++;
                                break;
          }
        use_escape = 0;         /*- no more consider string escape char -*/
}
/*
** ROUTINE:     get_next_token
**
** FUNCTIONAL DESCRIPTION:
**      returns the next recognized token
**
** INPUT PARAMETERS:
**      fd:             current file descritor
**
** OUTPUT PARAMETERS:
**      next token
**
** SIDE EFFECTS:
**      eat characters
*/
/*- ungot token stack and stack pointer                                 -*/
TOKEN buf_tok[80] = {OTHER};
int  buf_tok_ptr = -1;

TOKEN get_next_token(fd)
FILE *fd;
{
   register char c,c2;
   register TOKEN tok;
   register int i,j;
   int my_eof = EOF; /* make lint quiet */

        /*- loop for ever                                               -*/
        for(;;) {
          /*- token stack is not empty, unstack a token                 -*/
          if (buf_tok_ptr >= 0) {
                tok = buf_tok[buf_tok_ptr];
                buf_tok_ptr--;
                return(tok);
          }
          /*- is it end of file ?                                       -*/
          else if ((c=get_next_char(fd,IGNORE_VOID)) == (char)my_eof) {
              return(EOF_TK);
          }
          /*- is it end of line ?                                       -*/
          else if (c == t_desc->eol) {
            /* reset current line descriptors   -*/
            has_comment_line = 0;
            has_inst_line = 0;
            cur_line_number++;          /*- inc line counter            -*/
            col_in_line = 0;            /*- reset position in line      -*/
            if (is_void_line) {         /*- if line is void,inc void line ctr-*/
                cur_void_lines++;
                continue;
            }
            else {                      /*-if line not void, return EOL token-*/
                return(EOL_TK);
            }
          }
          /*- is it end of sentence ?                                   -*/
          if ((t_desc->eos) && (NORM_CHAR(c) == (t_desc->eos[0]))) {
                /*- look at all the characters of the comment delimitors -*/
                for (i = 1; t_desc->eos[i] ; i++) {
                   /*- stack the read char, in case it is not a comment  -*/
                   push_char(c2 = get_next_char(fd,ACCEPT_VOID));
                   if (NORM_CHAR(c2) != (t_desc->eos[i])) break;
                }
                if (! (t_desc->eos[i])) {
                  /*- it is an end of stat: ignore saved characters     -*/
                  reset_char();
                  return(EOS_TK);
                }
                else
                  /*- restored saved characeters                        -*/
                  while((c2 = pop_char()) != (char)0xff) unget_char(c2);
          }
          /*- is it a level 1 comment (eol terminated)                  -*/
          if ((t_desc->soc) && (NORM_CHAR(c) == (t_desc->soc[0]))) {
                /*- look at all the characters of the comment delimitors -*/
                for (i = 1; t_desc->soc[i] ; i++) {
                   /*- stack the read char, in case it is not a comment  -*/
                   push_char(c2 = get_next_char(fd,ACCEPT_VOID));
                   if (NORM_CHAR(c2) != (t_desc->soc[i])) break;
                }
                if (! (t_desc->soc[i])) {
                  /*- it is a start of comment: ignore saved characters -*/
                  reset_char();
                  comment_family = EOL_TERMINATED_COMMENT;
                  return(COMMENT_S);
                }
                else
                  /*- restored saved characeters                        -*/
                  while((c2 = pop_char()) != (char)0xff) unget_char(c2);
          }
          /*- is it a start of positional comment                       -*/
          for (j=0; j < NB_C; j++) {
            if (col_in_line != t_desc->position[j])
                continue;
            if (((t_desc->pos_c)[j])&&(NORM_CHAR(c)==((t_desc->pos_c)[j])[0])) {
                /*- look at all the characters of the comment delimitors -*/
                for (i = 1; ((t_desc->pos_c)[j])[i] ; i++) {
                   /*- stack the read char, in case it is not a comment  -*/
                   push_char(c2 = get_next_char(fd,ACCEPT_VOID));
                   if (NORM_CHAR(c2) != ((t_desc->pos_c)[j])[i]) break;
                }
                if (! (((t_desc->pos_c)[j])[i])) {
                  /*- it is a start of comment: ignore saved characters -*/
                  reset_char();
                  comment_family = POSITIONAL_COMMENT;
                  comment_rank = j;
                  return(COMMENT_S);
                }
                else
                  /*- restored saved characeters                        -*/
                  while((c2 = pop_char()) != (char)0xff) unget_char(c2);
            }
          }
          /*- is it a start of comment ? loop on all the comment delimitors-*/
          if ((! is_in_cmt) || (t_desc->in_comment == 1)) {
           for (j=0; j < NB_C; j++) {
            if(((t_desc->start_c)[j])&&(NORM_CHAR(c)==((t_desc->start_c)[j])[0])) {
                /*- look at all the characters of the comment delimitors -*/
                for (i = 1; ((t_desc->start_c)[j])[i] ; i++) {
                   /*- stack the read char, in case it is not a comment  -*/
                   push_char(c2 = get_next_char(fd,ACCEPT_VOID));
                   if (NORM_CHAR(c2) != ((t_desc->start_c)[j])[i]) break;
                }
                if (! (((t_desc->start_c)[j])[i])) {
                  /*- it is a start of comment: ignore saved characters -*/
                  reset_char();
                  comment_family = NESTED_COMMENT;
                  comment_rank = j;
                  return(COMMENT_S);
                }
                else
                  /*- restored saved characeters                        -*/
                  while((c2 = pop_char()) != (char)0xff) unget_char(c2);
            }
           }
          }
          /*- is it an end of comment ? loop on all the comment delimitors-*/
          if (is_in_cmt) {
            for (j=0; j < NB_C; j++) {
             if (((t_desc->end_c)[j])&&(NORM_CHAR(c)==((t_desc->end_c)[j])[0])){
                /*- look at all the characters of the comment delimitors -*/
                for (i = 1; ((t_desc->end_c)[j])[i] ; i++) {
                   /*- stack the read char, in case it is not a comment  -*/
                   push_char(c2 = get_next_char(fd,ACCEPT_VOID));
                   if (NORM_CHAR(c2) != ((t_desc->end_c)[j])[i]) break;
                }
                if (! (((t_desc->end_c)[j])[i])) {
                  /*- it is an end of comment: ignore saved characters  -*/
                  reset_char();
                  comment_family = NESTED_COMMENT;
                  comment_rank = j;
                  return(COMMENT_E);
                }
                else
                  /*- restored saved characeters                        -*/
                  while((c2 = pop_char()) != (char)0xff) unget_char(c2);
             }
            }
          }
          /*- look at alternate rules (command level)                      -*/
          if (look_alternate_rules) {
            /*- is it a level 1 comment (eol terminated)                -*/
            if ((rule_desc.soc) && (NORM_CHAR(c) == (rule_desc.soc)[0])) {
                /*- look at all the characters of the comment delimitors -*/
                for (i = 1; rule_desc.soc[i] ; i++) {
                   /*- stack the read char, in case it is not a comment  -*/
                   push_char(c2 = get_next_char(fd,ACCEPT_VOID));
                   if (NORM_CHAR(c2) != (rule_desc.soc)[i]) break;
                }
                if (! (rule_desc.soc)[i]) {
                  /*- it is a start of comment: ignore saved characters -*/
                  reset_char();
                  comment_family = EOL_TERMINATED_COMMENT;
                  return(COMMENT_S);
                }
                else
                  /*- restored saved characters                         -*/
                  while((c2 = pop_char()) != (char)0xff) unget_char(c2);
            }
            /*- is it a nested start of comment ?                       -*/
            if ((! is_in_cmt) || (t_desc->in_comment == 1)) {
             if(((rule_desc.start_c)[0])&&(NORM_CHAR(c)==((rule_desc.start_c)[0][0]))){
                /*- look at all the characters of the comment delimitors -*/
                for (i = 1; ((rule_desc.start_c)[0][i]) ; i++) {
                   /*- stack the read char, in case it is not a comment  -*/
                   push_char(c2 = get_next_char(fd,ACCEPT_VOID));
                   if (NORM_CHAR(c2) != (((rule_desc.start_c)[0])[i])) break;
                }
                if (! (((rule_desc.start_c)[0])[i])) {
                  /*- it is a start of comment: ignore saved characters -*/
                  reset_char();
                  comment_family = NESTED_COMMENT;
                  comment_rank = -1;
                  return(COMMENT_S);
                }
                else
                  /*- restored saved characters                         -*/
                  while((c2 = pop_char()) != (char)0xff) unget_char(c2);
             }
            }
            /*- is it a nested end of comment ?                         -*/
            if (is_in_cmt) {
             if(((rule_desc.end_c)[0])&&(NORM_CHAR(c)==((rule_desc.end_c)[0][0]))){
                /*- look at all the characters of the comment delimitors -*/
                for (i = 1; ((rule_desc.end_c)[0][i]) ; i++) {
                   /*- stack the read char, in case it is not a comment  -*/
                   push_char(c2 = get_next_char(fd,ACCEPT_VOID));
                   if (NORM_CHAR(c2) != (((rule_desc.end_c)[0])[i])) break;
                }
                if (! (((rule_desc.end_c)[0])[i])) {
                  /*- it is an end of comment: ignore saved characters  -*/
                  reset_char();
                  comment_family = NESTED_COMMENT;
                  comment_rank = -1;
                  return(COMMENT_E);
                }
                else
                  /*- restored saved characeters                        -*/
                  while((c2 = pop_char()) != (char)0xff) unget_char(c2);
             }
            }
          }
          /*- possibly a character definition should hide a start of string-*/
          if (c == t_desc->char_id)
                return(CHAR_SEP);
          /*- possibly a string should hide a start of comment  -*/
          else if (c == t_desc->string_sep)
                return(STRING_SEP);
          else {
                is_void_line = 0;
                return(OTHER);
          }
        }
}
/*
** ROUTINE:     unget_token
**
** FUNCTIONAL DESCRIPTION:
**      un-read a token (push it on a token stack). The next get_next_token
**      will use this token.
**
** INPUT PARAMETERS:
**      t:              the token to be un-read
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      -
*/
void unget_token(t)
TOKEN t;
{
        if( ++buf_tok_ptr == (sizeof(buf_tok)/sizeof(TOKEN))) {
                print_error("unget token buffer full !\n",(char *)0,(char *)0);
                buf_tok_ptr--;
        }
        buf_tok[buf_tok_ptr] = t;
}
/*
** ROUTINE:     get_next_char
**
** FUNCTIONAL DESCRIPTION:
**      get the next non void char. deals with character level counter
**      and manage the string escape characters (especially awful when one
**      escape an end of line !!)
**
** INPUT PARAMETERS:
**      fd:             current file descriptor
**      behavior:       ACCEPT_VOID if void chars are to be returned
**                      IGNORE_VOID otherwise
**
** OUTPUT PARAMETERS:
**      returns the next read character.
**
** SIDE EFFECTS:
**      -
*/
/*- character stack and stack pointer, to be able to un-read characters -*/
char buf_char[80] = {0xff};
int  buf_char_ptr = -1;

char get_next_char(fd,behavior)
FILE *fd;
int behavior;
{
   register char *p,c;
   register int read_char;
   int is_void = 1;

   /*- loop until a character is non void                               -*/
   while(is_void) {
        if (buf_char_ptr >= 0) {
          /*- if the character stack is not empty, use it               -*/
          c = buf_char[buf_char_ptr];
          buf_char_ptr--;
          return(c);
        }
        /*- if end of file, job is done                                 -*/
        else if ((read_char=fgetc(fd)) == EOF)
          return((char)read_char);
        c = (char)read_char;
        col_in_line++;
        cur_char_number++;      /*- inc char counter                    -*/
        if (is_in_cmt)
          cur_char_in_cmt++;    /*- if in comment, inc comment char ctr -*/
        if ((c == t_desc->string_esc) && use_escape) {
          c = fgetc(fd);        /*- if it is the escape string character-*/
          col_in_line++;
          cur_char_number++;    /*- do not return it                    -*/
#ifdef TRACE
if(c=='\n')printf(":%dv%dp%dc%dd%di%d",cur_line_number,cur_void_lines,
cur_pcmt_lines,cur_cmt_lines,cur_code_lines,cur_code_stats);
#endif
          if (c == t_desc->eol) { /*- if the escaped char is an End of Line-*/
            has_inst_line = 0;  /*- reset instruction marker            -*/
            cur_line_number++;  /*- inc line counter                    -*/
            cur_code_lines++;   /*- inc code lines counter (strings are code)-*/
            col_in_line = 0;    /*- reset position in line              -*/
          }
#ifdef TRACE
putc(c,stdout);
#endif
          is_void = 1;
        }
        else {
          /*- check if the char is or not a void one                    -*/
          is_void = 0;
          if (behavior == IGNORE_VOID) {
            for(p=t_desc->voidc; *p; p++)
              if (c == *p) {
                is_void = 1;
                break;
              }
          }
        }
   }
#ifdef TRACE
if(c=='\n')printf(":%dv%dp%dc%dd%di%d",cur_line_number,cur_void_lines,
cur_pcmt_lines,cur_cmt_lines,cur_code_lines,cur_code_stats);
putc(c,stdout);
#endif
   return(c);
}
/*
** ROUTINE:     unget_char
**
** FUNCTIONAL DESCRIPTION:
**      un-read a char (push it on a character stack). The next get_next_char
**      will use this car.
**
** INPUT PARAMETERS:
**      c:              the characater to be un-read
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      -
*/
void unget_char(c)
char c;
{
        if( ++buf_char_ptr == (sizeof(buf_char)/sizeof(char))) {
                print_error("unget buffer full !\n",(char *)0,(char *)0);
                buf_char_ptr--;
        }
        buf_char[buf_char_ptr] = c;
}
/*
** ROUTINE:     push_char
**
** FUNCTIONAL DESCRIPTION:
**      temporary storage of characters
**
** INPUT PARAMETERS:
**      c:              the characater to be pushed
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      -
*/
/*- character stack and stack pointer, to be able to store characters   -*/
char stack_char[80] = {0xff} ;
int  stack_char_ptr = -1;

void push_char(c)
char c;
{
        if( ++stack_char_ptr == (sizeof(stack_char)/sizeof(char))) {
                print_error("char stack full !\n",(char *)0,(char *)0);
                stack_char_ptr--;
        }
        stack_char[stack_char_ptr] = c;
}
/*
** ROUTINE:     pop_char
**
** FUNCTIONAL DESCRIPTION:
**      read temporary storage of characters
**
** INPUT PARAMETERS:
**      -
**
** OUTPUT PARAMETERS:
**      returns the current pushed characater
**
** SIDE EFFECTS:
**      -
*/

char pop_char()
{
        if (stack_char_ptr >= 0)
          return(stack_char[stack_char_ptr--]);
        else
          return((char)0xff);
}
/*
** ROUTINE:     reset_char
**
** FUNCTIONAL DESCRIPTION:
**      reset temporary storage of characters
**
** INPUT PARAMETERS:
**      -
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      -
*/

void reset_char()
{
        stack_char_ptr = -1;
}
/*
** ROUTINE:     print_result
**
** FUNCTIONAL DESCRIPTION:
**      print result
**
** INPUT PARAMETERS:
**      fn:             the file name whose results are to be printed
**                      (NULL to print the total)
**      cumul:          if >=0, it is a cumulated result
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      use the 'is_verbose' global flag
*/
void print_result(fn,cumul)
char *fn;
int cumul;
{
    if(is_wcl_style) {
	print_result_wcl(fn,cumul);
    }
    else {
        if (fn == NULL) {
          if (is_verbose) {
            if (is_s132) {
              dummy = fprintf(outfile,CVDFORMAT132,"Total",
                tot_line_number,
                tot_code_lines,
                tot_code_stats,
                tot_pcmt_lines,
                tot_cmt_lines - tot_pcmt_lines,
                tot_void_lines,
                tot_char_number,
                tot_char_in_cmt,
                cumul);
            }
            else {
              dummy = fprintf(outfile,CVDFORMAT,"Total",
                tot_line_number,
                tot_code_lines,
                tot_code_stats,
                tot_pcmt_lines,
                tot_cmt_lines - tot_pcmt_lines,
                tot_void_lines,
                tot_char_number,
                tot_char_in_cmt,
                cumul);
            }
          }
          else {
            if (is_s132) {
              dummy = fprintf(outfile,CNDFORMAT132,"Total",
                tot_line_number,
                tot_code_lines,
                tot_code_stats,
                tot_pcmt_lines,
                tot_cmt_lines - tot_pcmt_lines,
                cumul);
            }
            else {
               dummy = fprintf(outfile,CNDFORMAT,"Total",
                 tot_line_number,
                 tot_code_lines,
                 tot_code_stats,
                 tot_pcmt_lines,
                 tot_cmt_lines - tot_pcmt_lines,
                 cumul);
            }
          }
        }
        else if (cumul >= 0) {
          if (is_verbose) {
            if (is_s132) {
              dummy = fprintf(outfile,CVDFORMAT132,fn,
                cur_line_number,
                cur_code_lines,
                cur_code_stats,
                cur_pcmt_lines,
                cur_cmt_lines - cur_pcmt_lines,
                cur_void_lines,
                cur_char_number,
                cur_char_in_cmt,
                cumul);
            }
            else {
              dummy = fprintf(outfile,CVDFORMAT,fn,
                cur_line_number,
                cur_code_lines,
                cur_code_stats,
                cur_pcmt_lines,
                cur_cmt_lines - cur_pcmt_lines,
                cur_void_lines,
                cur_char_number,
                cur_char_in_cmt,
                cumul);
            }
          }
          else {
            if (is_s132) {
              dummy = fprintf(outfile,CNDFORMAT132,fn,
                cur_line_number,
                cur_code_lines,
                cur_code_stats,
                cur_pcmt_lines,
                cur_cmt_lines - cur_pcmt_lines,
                cumul);
            }
            else {
               dummy = fprintf(outfile,strlen(fn) > 20 ? ECNDFORMAT : CNDFORMAT,fn,
                 cur_line_number,
                 cur_code_lines,
                 cur_code_stats,
                 cur_pcmt_lines,
                 cur_cmt_lines - cur_pcmt_lines,
                 cumul);
             }
          }
        }
        else {
          if (is_verbose) {
            if (is_s132) {
              dummy = fprintf(outfile,VDFORMAT132,fn,
                cur_line_number,
                cur_code_lines,
                cur_code_stats,
                cur_pcmt_lines,
                cur_cmt_lines - cur_pcmt_lines,
                cur_void_lines,
                cur_char_number,
                cur_char_in_cmt);
            }
            else {
              dummy = fprintf(outfile,VDFORMAT,fn,
                cur_line_number,
                cur_code_lines,
                cur_code_stats,
                cur_pcmt_lines,
                cur_cmt_lines - cur_pcmt_lines,
                cur_void_lines,
                cur_char_number,
                cur_char_in_cmt);
            }
          }
          else {
            if (is_s132) {
              dummy = fprintf(outfile,NDFORMAT132,fn,
                cur_line_number,
                cur_code_lines,
                cur_code_stats,
                cur_pcmt_lines,
                cur_cmt_lines - cur_pcmt_lines);
             }
             else {
               dummy = fprintf(outfile,strlen(fn) > 20 ? ENDFORMAT : NDFORMAT,fn,
                 cur_line_number,
                 cur_code_lines,
                 cur_code_stats,
                 cur_pcmt_lines,
                 cur_cmt_lines - cur_pcmt_lines);
             }
          }
        }
    }
}
/*
** ROUTINE:     print_result_wcl
**
** FUNCTIONAL DESCRIPTION:
**      print result in "wc -l" style
**
** INPUT PARAMETERS:
**      fn:             the file name whose results are to be printed
**                      (NULL to print the total)
**      cumul:          if >=0, it is a cumulated result
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**      "verbose" and "132" flags ignored; "cumul" ignored.
*/
void print_result_wcl(fn,cumul)
char *fn;
int cumul;
{
    if (fn == NULL) {
	dummy = fprintf(outfile,"%8d %s\n",tot_code_lines,"total");
    }
    else {
	dummy = fprintf(outfile,"%8d %s\n",cur_code_lines,fn);
    }
}
/*
** ROUTINE:     print_error
**
** FUNCTIONAL DESCRIPTION:
**      print error
**
** INPUT PARAMETERS:
**      pattern:        a printf-like pattern with up to 2 fields
**      arg1...:        arguments to pattern
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**
*/
void print_error(pattern,arg1,arg2)
char *pattern;
char *arg1;
char *arg2;
{
        dummy = fprintf(outfile,pattern,arg1,arg2);
        /*- try to avoid double printing on tty                 -*/
        if (outfile != stdout)
          dummy = fprintf(stderr,pattern,arg1,arg2);
        global_return = 1;
}
/*
** ROUTINE:     print_usage
**
** FUNCTIONAL DESCRIPTION:
**      print usage
**
** INPUT PARAMETERS:
*       -
**
** OUTPUT PARAMETERS:
**      -
**
** SIDE EFFECTS:
**
*/
void print_usage()
{
        dummy = fprintf(stderr,"\
Source code Lines CouNTer  release: %s  - Thales TRT / ATGL\n\
\n\
Usage: \tslcnt\t[-l language]\n\
                [-o output_file]\n\
                [-c eol_terminated_comment_start]\n\
                [-cs start_of_nested_comment]\n\
                [-ce end_of_nested_comment]\n\
                [-v]   {providing for an extended results display (verbose)}\n\
                [-132] {providing for a 132 columns output}\n\
                [-wcl] {output in the 'wc -l' style}\n\
                [-e]   {providing for list files expansion}\n\
                [-p]   {disabling pre-expansion of command level list files}\n\
                filenames {wildcards not accepted for DOS or AEGIS}\n\
                    or listnames {.lst or .lst_src (lowercase) extension}\n\
                [-x filenames_to_exclude]\n",
        VERSION);
        dummy = fprintf(stderr,"\
\n\tslcnt\t-l <language> <filename> -comp <label1> <label2>\n") ;

        dummy = fprintf(stderr,"\n\
Output: LT: total number of lines\n\
        LS: number of source code lines\n\
        LI: number of source code lines containing at least one statement\n\
        LC: number of lines containing only comments\n\
        LM: number of lines mixing source code and comments\n\
        LV: number of empty lines (-v option)\n\
        CT: total number of characters in the file (-v option)\n\
        CC: total number of characters in comments (-v option)\n\
        NF: number of processed files (when a list)\n");

        dummy = fprintf(stderr,"\n\
       In 'wc -l' style, the output consists of one line per input file;\n\
       only the LS value is given for each file, along with the file name.\n\
       If more than 1 file is processed, an additional line provides the sum of\n\
       the LS values.\n\n\
       In ClearCase comparison mode (-comp option) <label1> and <label2> are\n\
       the ClearCase label for comparison.\n");
}
