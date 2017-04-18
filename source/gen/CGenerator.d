module gen.CGenerator;

import std.file;
import stdio = std.stdio;
import std.range;
import std.conv;

import util;
import syntax.ctree;
import syntax.transform;

public import gen.OutputBuilder;
import std.range;
import std.algorithm;

public auto cgenerate(CProgramNode node, CSymbolTable table, OutputStream outp)
{
    return new CGenerator(table, new OutputBuilder(outp)).apply(node);
}

private class CGenerator {
private:
    OutputBuilder *ob;
    alias ob this;
    CSymbolTable symtab;
public:
    this(CSymbolTable table, OutputBuilder *builder)
    {
        this.symtab = table;
        this.ob = builder;
    }

    invariant
    {
        assert(this.ob, "No output builder");
        assert(this.symtab, "No symbol table");
    }
    
    auto apply(CProgramNode node)
    {
        this.ob.printfln("/* Generated by the Aleph compiler v0.0.1 */");
        this.visit(node);
        return this.ob;
    }

    void visit(CProgramNode node)
    {
        foreach(x; node.children){
            this.visit(x);
        }
    }

    void visit(CTopLevelNode node)
    {
        node.match(
            (CFuncDeclNode func) => this.visit(func)
        );
    }

    void visit(CFuncDeclNode node)
    {
        this.untabbed({
            this.printf("%s %s %s(", node.storageClass.toString,
                                     node.returnType.typeString,
                                     node.name);
            node.parameters.headLast!(
                    i => this.printf("%s %s, ", i.type.typeString, i.name),
                    k => this.printf("%s %s", k.type.typeString, k.name));
            this.printfln(")");
        });
        this.visit(node.bodyNode);
    }

    void visit(CBlockStatementNode node)
    {
        this.block({
            node.children.each!(x => this.visit(x));
        });
    }

    void visit(CStatementNode node)
    {
        node.match(
            (CBlockStatementNode n) => this.visit(n),
            (CTypedefNode n) => this.visit(n),
            (CVarDeclNode n) => this.visit(n),
            (CStatementNode n){ this.printfln(";"); }
        );
    }

    void visit(CVarDeclNode node)
    {
        import std.string;
        this.statement({
            this.printf("%s %s %s", node.storageClass.toString, node.type.typeString, node.name);
            if(node.init){
                this.untabbed({
                    this.printf(" = %s", node.init.match((IntLiteral n) => n.value.to!string));
                });
            }
        });
    }

    void visit(CExpressionNode node)
    {
        node.match(
            (CLiteralNode x) => x.match((IntLiteral x) => x.value.to!string)
        );
    }

    void visit(CTypedefNode node)
    {
        this.printfln("typedef %s %s;", node.ctype.typeString, node.totype);
    }
};

private string typeString(CType t)
{
    import util;
    return t.use_err!(t => t.match((CPrimitive t) => t.name,
                            (CType t) => "unknown"))(new Exception("Null type"));
}

