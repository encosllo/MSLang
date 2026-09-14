\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{hjm1}[2000/10/19 v1.3.1 Houston Journal of Mathematics Class
(D. Wagner)]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{amsart}}
\ProcessOptions

\LoadClass[10pt]{amsart}

\def\@typesizes{%
       \or{5}{6.5}\or{6}{7.5}\or{7}{8.5}\or{8}{11}\or{9}{12}%
       \or{10}{13}% normalsize
       \or{\@xipt}{14}\or{\@xiipt}{15}\or{\@xivpt}{18}%
       \or{\@xviipt}{20}\or{\@xxpt}{24}}

\renewenvironment{proof}[1][\proofname]{\par \normalfont
  \topsep6\p@\@plus6\p@ \trivlist
  \item[\hskip\labelsep\scshape
    #1\@addpunct{.}]\ignorespaces
}{%
  \qed\endtrivlist
}

%This give the proper page layout.
\oddsidemargin=0in
\evensidemargin=0in
%\advance\oddsidemargin by -.5 true in
%\advance\evensidemargin by -.5 true in

\topmargin=-.3in
\headheight=.25in
\headsep=.2in
%\topskip=4.5mm
\textheight=6.8in
%\footskip=8.3mm
\textwidth=4.875in
%\brokenpenalty=10000


%This sets up thm, prop, lem, cor, dfn, rmk the way we want them.

%Definitions should have the `definition' theoremstyle!
\theoremstyle{definition}
\newtheorem{dfn}{Definition}

%Remarks should have the `remark' theoremstyle, with no numbers!
\theoremstyle{remark}
\newtheorem*{rmk}{Remark}

%Other ``Theorems'' set in the plain theoremstyle.  This leaves
% plain as the default theoremstyle for the author's
% newtheorems.
\theoremstyle{plain}
\newtheorem{thm}{Theorem}[section]
\newtheorem{prop}[thm]{Proposition}
\newtheorem{lem}[thm]{Lemma}
\newtheorem{cor}[thm]{Corollary}

%This makes the "Houston Journal of Mathematics" heading for the
%firstpage.
\newcommand{\hjmvol}{}
\newcommand{\journalvol}[1]{\renewcommand{\hjmvol}{#1}}
\newcommand{\hjmno}{}
\newcommand{\journalno}[1]{\renewcommand{\hjmno}{#1}}
\newcommand{\hjmyear}{}
\newcommand{\journalyear}[1]{\renewcommand{\hjmyear}{#1}}

\newsavebox{\hjmtext}
\sbox{\hjmtext}{\small\textsc{Houston Journal of Mathematics}}
\newlength{\hjmlength}
\settowidth{\hjmlength}{\usebox{\hjmtext}}

\newcommand{\hjmtitle}{%
\newdimen\mybaseline\mybaseline=\baselineskip%
\hfill\parbox{\hjmlength}{\setlength{\baselineskip}{8pt}
\begin{center}
\usebox{\hjmtext}\\
{\tiny \copyright\ \hjmyear\ University of Houston}\\
{\tiny Volume \hjmvol, No. \hjmno, \hjmyear}
\end{center}
}
\setlength{\baselineskip}{\mybaseline}
%\renewcommand{\baselinestretch}{\mybaseline}
\vspace{2 pc}}
%\renewcommand{\baselinestretch}{1.1}


\def\commby#1{\def\@commby{Communicated by #1}}
\let\@commby=\@empty

\newcommand{\cha}{\commby{Herbert Amann}}
\newcommand{\cga}{\commby{Giles Auchmuty}}
\newcommand{\cdb}{\commby{David Bao}}
\newcommand{\chb}{\commby{Ha\"{\i}m Brezis}}
\newcommand{\cjd}{\commby{James Damon}}
\newcommand{\ckd}{\commby{Kenneth R. Davidson}}
\newcommand{\cle}{\commby{L. C. Evans}}
\newcommand{\crh}{\commby{Robert M. Hardt}}
\newcommand{\cjh}{\commby{Jutta Hausen}}
\newcommand{\cch}{\commby{Charles Hagopian}}
\newcommand{\cjj}{\commby{Johnny A. Johnson}}
\newcommand{\ckk}{\commby{Klaus Kaiser}}
\newcommand{\andl}{\commby{Andrzej Lelek}}
\newcommand{\cjn}{\commby{Jun-iti Nagata}}
\newcommand{\cbn}{\commby{Bernhard H. Neumann}}
\newcommand{\cvp}{\commby{Vern I. Paulsen}}
\newcommand{\cgp}{\commby{Gilles Pisier}}
\newcommand{\crs}{\commby{Ridgway Scott}}
\newcommand{\css}{\commby{Stephen W. Semmes}}
\newcommand{\cee}{\commby{the editors}}
\newcommand{\cgw}{\commby{George Washington}}
\newcommand{\cbj}{\commby{William B. Johnson}}
\newcommand{\cmr}{\commby{Min  Ru}}
\newcommand{\cyh}{\commby{Yasunao Hattori}}
\newcommand{\cmro}{\commby{Maurice  Rojas}}
\newcommand{\cmd}{\commby{Manfred Dugas}}
\newcommand{\cmg}{\commby{Mai Gehrke}}
\newcommand{\cbd}{\commby{Bernard Dacorogna}}
\newcommand{\cdbl}{\commby{David Blecher}}




\def\@maketitle{%
\hjmtitle%
  \normalfont\normalsize
  \let\@makefnmark\relax  \let\@thefnmark\relax
  \ifx\@empty\@date\else \@footnotetext{\@setdate}\fi
  \ifx\@empty\@subjclass\else \@footnotetext{\@setsubjclass}\fi
  \ifx\@empty\@keywords\else \@footnotetext{\@setkeywords}\fi
  \ifx\@empty\thankses\else \@footnotetext{%
    \def\par{\let\par\@par}\@setthanks}\fi
  \@mkboth{\@nx\shortauthors}{\@nx\shorttitle}%
%  \global\topskip42\p@\relax % 5.5pc
%  \global\topskip6\p@\relax %

  \@settitle
  \ifx\@empty\authors \else \@setauthors \fi
  \ifx\@empty\@commby
  \else
    \baselineskip18\p@
    \vtop{\centering{\small\@commby\@@par}%
      \global\dimen@i\prevdepth}\prevdepth\dimen@i
  \fi

  \ifx\@empty\@dedicatory
  \else
    \baselineskip18\p@
    \vtop{\centering{\small\itshape\@dedicatory\@@par}%
      \global\dimen@i\prevdepth}\prevdepth\dimen@i
  \fi
  \@setabstract
  \normalsize
  \if@titlepage
    \newpage
  \else
    \dimen@34\p@ \advance\dimen@-\baselineskip
    \vskip\dimen@\relax
  \fi
} % end \@maketitle


\endinput




