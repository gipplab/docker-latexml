FROM mathwebsearch/latexml-mws:latest
COPY latexml/zbl.opt /usr/local/share/perl5/site_perl/LaTeXML/resources/Profiles/
COPY latexml/zbl.sty /usr/local/share/perl5/site_perl/LaTeXML/texmf/
COPY latexml/zbl.sty.ltxml /usr/local/share/perl5/site_perl/LaTeXML/Package/

ENTRYPOINT [ "hypnotoad", "-f", "script/ltxmojo" ]