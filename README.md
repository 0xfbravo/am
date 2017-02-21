# am - Compiler
```
Universidade Federal Rural do Rio de Janeiro - UFRRJ
                  Compiladores 2016.2
-------
Alunos: Bianca Albuquerque & Fellipe Pimentel
Professor: Filipe Braida
```
### How To
  #### Declarações
  As declarações são realizadas sem a necessidade da explicitação do tipo da variável e/ou constante. É possível também declarar variáveis sem a necessidade de atribuição de valores inicialmente, utilizando o comando ```is {type}```, como nos exemplos abaixo.
  ```
  a is String
  b is Int
  c is Char
  d is Float
  foo = 10
  bar = 2.2
  test = 'a'
  string = "www##@@@!!$$"
  ```
  Para a definição de constantes, é obrigatória a utilização da instrução ```@``` antes do nome da variável.
  ```
  @a = "isso é uma constante"
  a = 10 // Isso vai dar um erro não muito agradável...
  ```

  #### Operações
  TODO:

  #### Tipos Primitivos
  ```
  Int (Integer)
  Float
  Char (Character)
  String
  Boolean (Bool)
  ```

  #### Extras
  TODO:

### EXTRAS TODO
  - Atribuição de múltiplas variáveis

### Problemas conhecidos
  - Corrigir ```\n``` nas funções
    - If/Else/ElseIf
    - Do-while
    - For
    - Switch/Case
  - Corrigir ```continue``` que está em looping infinito em alguns casos *GRAVE*
  - Corrigir ```break``` após um switch (looping infinito) *GRAVE*
  - Parâmetros da função estão sendo reconhecidos no escopo global *GRAVE*
