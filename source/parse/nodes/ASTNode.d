module parse.nodes.ASTNode;

import parse.nodes.ASTVisitor;

/* Currently, this is all we need,
 * all an ASTNode needs is a way to 
 * call the correct method in a visitor */
interface ASTNode {
    void visit(ASTVisitor visitor);
};
